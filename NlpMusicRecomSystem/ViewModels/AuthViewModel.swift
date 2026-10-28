//
//  AuthViewModel.swift
//  NlpMusicRecomSystem
//
import CryptoKit
import Foundation
import Combine
import AuthenticationServices
import FirebaseAuth

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
    private var currentNonce : String?

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
    func handlewithSignInWithAppleRequest(request: ASAuthorizationAppleIDRequest){
        request.requestedScopes = [.email,.fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        
       
    }
    func handlewithSignInWithAppleCompletition(result: Result<ASAuthorization,Error>) {
        if case .failure(_) = result {
            errorMessage = "Failed to sign in with Apple4"
        }
        else if case .success(let success) = result {
            if let appleCredential = success.credential as? ASAuthorizationAppleIDCredential{
                guard let nonce = currentNonce else{
                    errorMessage = "Invalid State: The Login Callback was received with a code challenge"
                    return
                }
                guard let identityToken = appleCredential.identityToken else{
                    print("Unable to fetch the identity token")
                    return
                }
                guard let identityTokenString = String(data: identityToken, encoding: String.Encoding.utf8) else{
                    print("Failed to convert identity token to string")
                    return
                }
                
                let credential = OAuthProvider.credential(providerID: .apple, idToken: identityTokenString, rawNonce: nonce)
                
                Task {
                    do {
                        // 'try await' ile çağırıyoruz; işlem bitene kadar bekler, hata fırlatırsa catch'e düşer
                        let response = try await authService.signInWithApple(credential: credential)
                        
                        // İşlem başarılı olduysa nonce'ı temizle
                        self.currentNonce = nil
                        
                        // İsteğe bağlı: UI güncellemesi veya yönlendirme
                        print("Apple ile giriş başarılı: \(response)")
                        
                        
                    } catch {
                        // Hata fırlatıldığında burası yakalar
                        self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
                        self.currentNonce = nil
                    }
                }
                
            }
        }
        
    }
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
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
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
