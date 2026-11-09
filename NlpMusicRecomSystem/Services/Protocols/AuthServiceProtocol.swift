//
//  AuthServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation
import Combine
import AuthenticationServices
import FirebaseAuth

/// A lightweight representation of the authenticated user,
/// decoupled from any specific Firebase type.
struct AuthUser: Equatable {
    let uid: String
    let email: String?
    var displayName: String? = nil
}

/// Defines the contract for authentication services.
///
/// The service is a stateless gateway to the auth backend: it deliberately holds no
/// "current user" of its own. `AuthManager` is the single owner of auth state.
protocol AuthServiceProtocol: AnyObject {
    /// Reads the signed-in user from the backend session once (e.g. to seed `AuthManager` at launch).
    func fetchCurrentUser() -> AuthUser?
    /// Calls `handler` on every auth state change (sign in / sign out / account deletion).
    /// The observation lasts until the returned cancellable is released.
    func observeAuthState(_ handler: @escaping (AuthUser?) -> Void) -> AnyCancellable

    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
    /// Configures a Sign in with Apple request (scopes + hashed nonce).
    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest)
    /// Completes Sign in with Apple using the authorization returned by Apple.
    func signInWithApple(authorization: ASAuthorization) async throws
    /// Re-authenticates (if needed), revokes the Apple token, deletes server data and the Firebase account.
    func deleteAccount(authorization: ASAuthorization) async throws
    /// Updates the signed-in user's display name and returns the updated user.
    func updateDisplayName(_ name: String) async throws -> AuthUser?

    /// Returns a fresh Firebase ID token for API authentication.
    /// The token is sent as `Authorization: Bearer <token>` in API requests.
    func getIDToken() async throws -> String
}
