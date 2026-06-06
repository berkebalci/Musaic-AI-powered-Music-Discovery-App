//
//  FirebaseAuthService.swift
//  NlpMusicRecomSystem
//

import Foundation
import Combine
import FirebaseAuth


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

    // MARK: - Init

    init() {
        // Seed with the current Firebase user (if already signed in from a previous session)
        let initial = Auth.auth().currentUser.map { AuthUser(uid: $0.uid, email: $0.email) }
        currentUserSubject = CurrentValueSubject(initial)

        // Listen for future auth state changes (sign in / sign out / token refresh)
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            let user = firebaseUser.map { AuthUser(uid: $0.uid, email: $0.email) }
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
}
