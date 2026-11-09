//
//  LoginView.swift
//  NlpMusicRecomSystem
//

import SwiftUI
import AuthenticationServices


struct LoginView: View {

    @ObservedObject var viewModel: AuthViewModel
    // @State private var showSignUp = false
    // @FocusState private var focusedField: AuthField?

    // private enum AuthField { case email, password }

    var body: some View {
        ZStack {
            // Background
            GradientBackground()

            // Subtle decorative glow
            VStack {
                Circle()
                    .fill(Theme.accentCyan.opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .offset(x: -60, y: -100)
                Spacer()
                Circle()
                    .fill(Theme.accentPurple.opacity(0.10))
                    .frame(width: 280, height: 280)
                    .blur(radius: 80)
                    .offset(x: 80, y: 60)
            }
            .ignoresSafeArea()

            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()

                        // Logo / Title
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Theme.accentCyan.opacity(0.15))
                                    .frame(width: 100, height: 100)
                                Image("musaiclogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .clipShape(Circle())
                            }

                            Text("Welcome Back")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.textPrimary)

                            Text("Sign in to continue your music journey")
                                .font(Theme.bodyFont)
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 44)
                        
                        // Sign in with Apple
                        SignInWithAppleButton(.signIn) { request in
                            viewModel.handlewithSignInWithAppleRequest(request: request)
                        } onCompletion: { result in
                            viewModel.handlewithSignInWithAppleCompletition(result: result)
                        }
                        .signInWithAppleButtonStyle(.whiteOutline)
                        .frame(height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .padding(.horizontal, 24)
                        .disabled(viewModel.isLoading)

                        // Loading indicator for Apple Sign In
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.top, 20)
                        }

                        // Errors are shown by the global banner in RootView

                        // Terms & Privacy Notice
                        Text(legalNoticeText)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.textTertiary)
                            .multilineTextAlignment(.center)
                            .tint(Theme.accentCyan)
                            .padding(.horizontal, 32)
                            .padding(.top, 24)

                    /*
                    HStack {
                        Rectangle().fill(Theme.cardBorder).frame(height: 1)
                        Text("or").font(Theme.captionFont).foregroundColor(Theme.textTertiary).padding(.horizontal, 12)
                        Rectangle().fill(Theme.cardBorder).frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 15)
                    // Form Card
                    VStack(spacing: 16) {
                        AuthTextField(
                            icon: "envelope.fill",
                            placeholder: "Email Address",
                            text: $viewModel.email,
                            keyboardType: .emailAddress,
                            isSecure: false
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                        AuthTextField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $viewModel.password,
                            keyboardType: .default,
                            isSecure: true
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit {
                            focusedField = nil
                            Task { await viewModel.signIn() }
                        }

                        // Error message
                        if let error = viewModel.errorMessage {
                            ErrorBanner(message: error)
                        }

                        // Sign In Button
                        Button {
                            focusedField = nil
                            Task { await viewModel.signIn() }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.accentCyan, Theme.accentPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 54)

                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)

                    // Divider
                    Spacer().frame(height: 20)
                    // Sign Up CTA
                    VStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.textSecondary)

                        Button("Create Account") {
                            viewModel.clearFields()
                            showSignUp = true
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.accentCyan, Theme.accentPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                    */

                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        /*
        .navigationDestination(isPresented: $showSignUp) {
            SignUpView(viewModel: viewModel)
        }
        */
    }

    // MARK: - Legal Notice

    private var legalNoticeText: AttributedString {
        let text = "Giriş yaparak [Kullanım Koşulları](\(AppLinks.termsOfUse.absoluteString)) ve [Gizlilik Sözleşmesi](\(AppLinks.privacyPolicy.absoluteString))'ni kabul etmiş olursunuz."
        if let attributed = try? AttributedString(markdown: text) {
            return attributed
        }
        return AttributedString("Giriş yaparak Kullanım Koşulları ve Gizlilik Sözleşmesi'ni kabul etmiş olursunuz.")
    }
}
