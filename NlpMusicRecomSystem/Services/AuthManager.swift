//
//  AuthManager.swift
//  NlpMusicRecomSystem
//

import Foundation
import Combine
import AuthenticationServices

/// Single source of truth for authentication state.
///
/// Created once (by `DIContainer`) and shared with every view / view model that needs to know
/// who is signed in. All session changes — sign in, sign out, account deletion — go through
/// here, so `RootView` always reacts to them immediately on the main thread.
@MainActor
final class AuthManager: ObservableObject {

    // MARK: - Published State

    /// The signed-in user. `nil` means the login flow should be shown.
    @Published private(set) var currentUser: AuthUser?

    var isAuthenticated: Bool { currentUser != nil }

    // MARK: - Private

    private let authService: any AuthServiceProtocol
    private var authStateCancellable: AnyCancellable?

    // MARK: - Init

    init(authService: any AuthServiceProtocol) {
        self.authService = authService
        self.currentUser = authService.fetchCurrentUser()

        authStateCancellable = authService.observeAuthState { [weak self] user in
            Task { @MainActor in
                self?.update(user)
            }
        }
    }

    // MARK: - Actions

    func signIn(email: String, password: String) async throws {
        try await authService.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await authService.signUp(email: email, password: password)
    }

    func signOut() {
        try? authService.signOut()
        update(nil)
    }

    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        authService.prepareAppleSignInRequest(request)
    }

    func signInWithApple(authorization: ASAuthorization) async throws {
        try await authService.signInWithApple(authorization: authorization)
        update(authService.fetchCurrentUser())
    }

    /// Deletes the account and explicitly clears the local session,
    /// guaranteeing that RootView immediately flips to the login screen.
    func deleteAccount(authorization: ASAuthorization) async throws {
        do {
            try await authService.deleteAccount(authorization: authorization)
        } catch {
            if authService.fetchCurrentUser() == nil {
                update(nil)
            }
            throw error
        }
        update(nil)
    }

    func updateDisplayName(_ name: String) async throws {
        if let updated = try await authService.updateDisplayName(name) {
            update(updated)
        }
    }

    // MARK: - Private

    private func update(_ user: AuthUser?) {
        guard currentUser != user else { return }
        currentUser = user
    }
}
