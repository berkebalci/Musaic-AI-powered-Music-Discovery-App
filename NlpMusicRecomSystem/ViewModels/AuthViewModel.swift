//
//  AuthViewModel.swift
//  NlpMusicRecomSystem
//
import Foundation
import Combine
import AuthenticationServices

/// Drives LoginView and SignUpView — holds field state, loading flag,
/// and surfaces user-readable error messages.
@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Published State

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Private

    /// Single owner of the auth session. This view model only drives form / loading / error state.
    private let authManager: AuthManager

    // MARK: - Init

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Actions

    func signIn() async {
        guard validate(mode: .signIn) else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
        isLoading = false
    }
    func handlewithSignInWithAppleRequest(request: ASAuthorizationAppleIDRequest){
        authManager.prepareAppleSignInRequest(request)
    }
    func handlewithSignInWithAppleCompletition(result: Result<ASAuthorization,Error>) {
        switch result {
        case .failure:
            errorMessage = "Failed to sign in with Apple4"
            isLoading = false
        case .success(let authorization):
            Task {
                do {
                    // Nonce doğrulama, Firebase girişi ve isim kaydı serviste yapılır
                    try await authManager.signInWithApple(authorization: authorization)
                    print("Apple ile giriş başarılı")
                    
                } catch {
                    self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Called by the delete-account sheet's Sign in with Apple button.
    /// The request is prepared with `handlewithSignInWithAppleRequest(request:)`;
    /// this receives the re-authentication result.
    func handleDeleteAccountWithAppleCompletion(result: Result<ASAuthorization, Error>) {
        isLoading = true

        switch result {
        case .failure(let error):
            self.errorMessage = "Apple doğrulaması başarısız: \(error.localizedDescription)"
            self.isLoading = false

        case .success(let authorization):
            Task {
                defer { self.isLoading = false }
                do {
                    // Reauth, token revoke, server data and Firebase deletion happen in the service;
                    // AuthManager then clears the session, which makes RootView show the login screen.
                    try await authManager.deleteAccount(authorization: authorization)
                    self.errorMessage = nil
                } catch {
                    print("❌ Hesap silme başarısız: \(error)")
                    self.errorMessage = "Hesap silme başarısız: \(error.localizedDescription)"
                }
            }
        }
    }

    func signUp() async {
        guard validate(mode: .signUp) else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await authManager.signUp(email: email, password: password)
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
        isLoading = false
    }

    func signOut() {
        authManager.signOut()
    }

    func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
    }

    // MARK: - Validation

    private enum Mode { case signIn, signUp }

    private func validate(mode: Mode) -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email address."
            return false
        }
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        if mode == .signUp {
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match."
                return false
            }
        }
        return true
    }

    // MARK: - Error Mapping

    private func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case 17004: return "Invalid email or password."
        case 17007: return "An account already exists with this email."
        case 17008: return "The email address is badly formatted."
        case 17009: return "Incorrect password. Please try again."
        case 17011: return "No account found with this email."
        case 17020: return "Network error. Please check your connection."
        default:    return error.localizedDescription
        }
    }
}
