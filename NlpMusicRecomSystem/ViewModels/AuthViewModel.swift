//
//  AuthViewModel.swift
//  NlpMusicRecomSystem
//

import Foundation
import Combine

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

    private let authService: any AuthServiceProtocol

    // MARK: - Init

    init(authService: any AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Actions

    func signIn() async {
        guard validate(mode: .signIn) else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
        isLoading = false
    }

    func signUp() async {
        guard validate(mode: .signUp) else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signUp(email: email, password: password)
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
        isLoading = false
    }

    func signOut() {
        try? authService.signOut()
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
