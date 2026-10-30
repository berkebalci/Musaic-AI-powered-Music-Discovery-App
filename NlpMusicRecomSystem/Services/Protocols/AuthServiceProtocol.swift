//
//  AuthServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation
import Combine
import FirebaseAuth

/// A lightweight representation of the authenticated user,
/// decoupled from any specific Firebase type.
struct AuthUser: Equatable {
    let uid: String
    let email: String?
    var displayName: String? = nil
}

/// Defines the contract for authentication services.
protocol AuthServiceProtocol: AnyObject {
    /// Publishes the current user. `nil` when not signed in.
    var currentUserPublisher: AnyPublisher<AuthUser?, Never> { get }
    /// The current user synchronously, if signed in.
    var currentUser: AuthUser? { get }

    func signIn(email: String, password: String) async throws
    //func signInWithApple() async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
    func signInWithApple(credential: OAuthCredential)async throws ->  AuthDataResult
    /// Updates the signed-in user's display name (e.g. Apple full name, only provided on first sign-in).
    func updateDisplayName(_ name: String) async throws
    /// Returns a fresh Firebase ID token for API authentication.
    /// The token is sent as `Authorization: Bearer <token>` in API requests.
    func getIDToken() async throws -> String
}
