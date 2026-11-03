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

    // MARK: - Publisher

    var currentUserPublisher: AnyPublisher<AuthUser?, Never> {
        currentUserSubject.eraseToAnyPublisher()
    }

    var currentUser: AuthUser? {
        currentUserSubject.value
    }

    // MARK: - Private

    private let currentUserSubject: CurrentValueSubject<AuthUser?, Never>
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    /// Raw nonce of the in-flight Sign in with Apple request (its SHA256 is sent to Apple).
    private var currentNonce: String?

    // MARK: - Init

    init() {
        // Seed with the current Firebase usesr (if already signed in from a previous session)
        let initial = Auth.auth().currentUser.map { AuthUser(uid: $0.uid, email: $0.email, displayName: $0.displayName) }
        currentUserSubject = CurrentValueSubject(initial)

        // Listen for future auth state changes (sign in / sign out / token refresh)
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            let user = firebaseUser.map { AuthUser(uid: $0.uid, email: $0.email, displayName: $0.displayName) }
            self?.currentUserSubject.send(user)
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - AuthServiceProtocol

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
    func signInWithApple(authorization: ASAuthorization) async throws {
        let credential = try makeAppleCredential(from: authorization)
        try await Auth.auth().signIn(with: credential)

        // Apple only provides fullName on the first sign-in; failing to save it must not fail the sign-in.
        if let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let nameComponents = appleCredential.fullName {
            let fullName = PersonNameComponentsFormatter().string(from: nameComponents)
            if !fullName.isEmpty {
                try? await updateDisplayName(fullName)
            }
        }
    }
    
    func deleteUserAccount() async -> Bool{
        guard let user = Auth.auth().currentUser else { return false}
        guard let lastSigninDate = user.metadata.lastSignInDate else { return false}
        let userNeedsReAuth = !lastSigninDate.isWithinPast(5, .minute)
        if userNeedsReAuth {
            
        }
        return false

    }

    func updateDisplayName(_ name: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        // Auth state listener does not fire on profile changes, so publish the update manually
        currentUserSubject.send(AuthUser(uid: user.uid, email: user.email, displayName: name))
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
