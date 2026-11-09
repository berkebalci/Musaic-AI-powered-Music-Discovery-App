//
//  FirebaseAuthService.swift
//  NlpMusicRecomSystem
//

import Foundation
import Combine
import FirebaseAuth
import AuthenticationServices
import CryptoKit


/// Concrete implementation of `AuthServiceProtocol` backed by Firebase Authentication.
final class FirebaseAuthService: AuthServiceProtocol {

    // MARK: - Private

    /// Raw nonce of the in-flight Sign in with Apple request (its SHA256 is sent to Apple).
    private var currentNonce: String?

    // MARK: - Init

    /// Stateless with respect to the signed-in user: the session lives in Firebase and
    /// `AuthManager` is the only object that mirrors it for the UI.
    init() {}

    // MARK: - AuthServiceProtocol
    @MainActor
    func fetchCurrentUser() -> AuthUser? {
        Auth.auth().currentUser.map(Self.makeAuthUser)
    }
    @MainActor
    func observeAuthState(_ handler: @escaping (AuthUser?) -> Void) -> AnyCancellable {
        let handle = Auth.auth().addStateDidChangeListener { _, firebaseUser in
            handler(firebaseUser.map(Self.makeAuthUser))
        }
        return AnyCancellable {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    // MARK: - Sign in with Apple

    /// Configures the Apple ID request: scopes + a hashed nonce.
    /// The raw nonce is kept here and verified by Firebase in `signInWithApple(authorization:)`.
    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email, .fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }

    /// Validates the Apple authorization and builds a Firebase `OAuthCredential`.
    /// Shared by both Sign in with Apple and Re-authentication flows.
    func makeAppleCredential(from authorization: ASAuthorization) throws -> OAuthCredential {
        // The nonce is single-use: clear it whatever the outcome.
        defer { currentNonce = nil }

        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AppleSignInError.invalidCredential
        }
        guard let nonce = currentNonce else {
            throw AppleSignInError.missingNonce
        }
        guard let identityToken = appleCredential.identityToken else {
            throw AppleSignInError.missingIdentityToken
        }
        guard let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            throw AppleSignInError.invalidIdentityToken
        }

        return OAuthProvider.credential(
            providerID: .apple,
            idToken: identityTokenString,
            rawNonce: nonce
        )
    }

    /// Exchanges Apple's authorization for a Firebase session.
    /// On the first sign-in Apple also returns the user's full name, which is saved as `displayName`.
    func signInWithApple(authorization: ASAuthorization) async throws{
        let credential = try makeAppleCredential(from: authorization)
        try await Auth.auth().signIn(with: credential)

        // Apple only provides fullName on the first sign-in; failing to save it must not fail the sign-in.
        if let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let nameComponents = appleCredential.fullName {
            let fullName = PersonNameComponentsFormatter().string(from: nameComponents)
            if !fullName.isEmpty {
                _ = try? await updateDisplayName(fullName)
            }
        }
        
    }
    
    /// Deletes the signed-in user's account:
    /// 1. re-authenticates with Apple when the last sign-in is older than 5 minutes,
    /// 2. revokes the Apple token (required by App Store guidelines for Apple-linked accounts),
    /// 3. deletes server-side data with a fresh ID token (must happen before the Firebase user is gone),
    /// 4. deletes the Firebase user.
    /// Firebase's auth listener then reports `nil`, which `AuthManager` turns into a sign-out.
    func deleteAccount(authorization: ASAuthorization) async throws {
        guard let user = Auth.auth().currentUser,
              let lastSignInDate = user.metadata.lastSignInDate else {
            throw AuthServiceError.noSignedInUser
        }

        let needsReAuth = !lastSignInDate.isWithinPast(5, .minute)
        let needsTokenRevoke = user.providerData.contains { $0.providerID == "apple.com" }

        print("🗑️ [deleteAccount] needsReAuth=\(needsReAuth), needsTokenRevoke=\(needsTokenRevoke)")

        if needsReAuth {
            let credential = try makeAppleCredential(from: authorization)
            try await user.reauthenticate(with: credential)
            print("🗑️ [deleteAccount] 1/4 reauthenticate OK")
        }

        if needsTokenRevoke {
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let authCodeData = appleCredential.authorizationCode,
                  let authCode = String(data: authCodeData, encoding: .utf8) else {
                throw AuthServiceError.missingAuthorizationCode
            }
            try await Auth.auth().revokeToken(withAuthorizationCode: authCode)
            print("🗑️ [deleteAccount] 2/4 Apple token revoke OK")
        }

        let freshToken = try await user.getIDToken(forcingRefresh: true)
        try await deleteAccountOnServer(idToken: freshToken)
        print("🗑️ [deleteAccount] 3/4 server data deletion OK")

        do {
            try await user.delete()
            print("🗑️ [deleteAccount] 4/4 Firebase user.delete() OK")
            try? Auth.auth().signOut()
        } catch {
            // The Firebase user can already be gone at this point (the backend only deletes Firestore
            // data, so the likely culprit is an earlier step such as the Apple token revoke or an
            // external trigger). The account no longer exists either way, so end the local session
            // instead of surfacing an error and leaving the user stuck on the profile screen.
            let code = AuthErrorCode(rawValue: (error as NSError).code)
            switch code {
            case .userNotFound, .userTokenExpired, .invalidUserToken, .userDisabled:
                print("ℹ️ [deleteAccount] 4/4 Firebase user already gone (\(error.localizedDescription)); signing out locally.")
                try? Auth.auth().signOut()
            default:
                print("❌ Firebase user.delete() failed: \(error)")
                throw error
            }
        }
    }

    /// Sends a `DELETE /api/account` request to the FastAPI backend so it can remove
    /// the user's server-side (Firestore) data. The Firebase Auth user is deleted by the app.
    /// - Parameter idToken: A fresh Firebase ID token, sent as `Authorization: Bearer <token>`.
    private func deleteAccountOnServer(idToken: String) async throws {
        var request = URLRequest(url: APIEnvironment.accountURL)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 30
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw APIError.networkUnavailable
        } catch {
            throw APIError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401, 403:
            throw APIError.authenticationRequired
        default:
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
    }

    func updateDisplayName(_ name: String) async throws -> AuthUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        // The auth state listener does not fire on profile changes; the caller publishes the result.
        return AuthUser(uid: user.uid, email: user.email, displayName: name)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    /// Returns a fresh Firebase ID token for API authentication.
    /// The token is automatically refreshed if expired.
    /// Includes a brief retry to handle race conditions during auth state sync.
    func getIDToken() async throws -> String {
        // If currentUser is nil, wait briefly for auth state to sync
        // This handles the race condition where chat navigates before Firebase is ready
        if Auth.auth().currentUser == nil {
            print("⏳ Firebase currentUser nil — waiting for auth state sync...")
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        }

        guard let user = Auth.auth().currentUser else {
            print("❌ Firebase currentUser is still nil after retry. User may not be signed in.")
            throw APIError.authenticationRequired
        }

        let token = try await user.getIDToken()
        print("🔑 Firebase ID Token alındı (ilk 20 karakter): \(String(token.prefix(20)))...")
        return token
    }

    // MARK: - Mapping

    private static func makeAuthUser(_ user: User) -> AuthUser {
        AuthUser(uid: user.uid, email: user.email, displayName: user.displayName)
    }

    // MARK: - Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

// MARK: - Errors

enum AuthServiceError: LocalizedError {
    case noSignedInUser
    case missingAuthorizationCode

    var errorDescription: String? {
        switch self {
        case .noSignedInUser:           return "Kullanıcı oturumu bulunamadı."
        case .missingAuthorizationCode: return "Apple authorization code alınamadı."
        }
    }
}

enum AppleSignInError: LocalizedError {
    case invalidCredential
    case missingNonce
    case missingIdentityToken
    case invalidIdentityToken

    var errorDescription: String? {
        switch self {
        case .invalidCredential:    return "Unexpected Apple credential type."
        case .missingNonce:         return "Invalid State: The Login Callback was received with a code challenge"
        case .missingIdentityToken: return "Unable to fetch the identity token"
        case .invalidIdentityToken: return "Failed to convert identity token to string"
        }
    }
}
