//
//  SignUpView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct SignUpView: View {

    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: AuthField?

    private enum AuthField { case email, password, confirmPassword }

    var body: some View {
        ZStack {
            GradientBackground()

            // Decorative glows
            VStack {
                Circle()
                    .fill(Theme.accentPurple.opacity(0.12))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: 80, y: -80)
                Spacer()
                Circle()
                    .fill(Theme.accentCyan.opacity(0.08))
                    .frame(width: 260, height: 260)
                    .blur(radius: 80)
                    .offset(x: -80, y: 60)
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.accentPurple.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.accentPurple, Theme.accentCyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)

                        Text("Start discovering music tailored for you")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 44)

                    // Form
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
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirmPassword }

                        AuthTextField(
                            icon: "lock.rotation",
                            placeholder: "Confirm Password",
                            text: $viewModel.confirmPassword,
                            keyboardType: .default,
                            isSecure: true
                        )
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.go)
                        .onSubmit {
                            focusedField = nil
                            Task { await viewModel.signUp() }
                        }

                        // Password hint
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                            Text("Password must be at least 6 characters")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Theme.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                        // Error message
                        if let error = viewModel.errorMessage {
                            ErrorBanner(message: error)
                        }

                        // Sign Up Button
                        Button {
                            focusedField = nil
                            Task { await viewModel.signUp() }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.accentPurple, Theme.accentCyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 54)

                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)

                    // Back to Sign In
                    HStack {
                        Rectangle().fill(Theme.cardBorder).frame(height: 1)
                        Text("or").font(Theme.captionFont).foregroundColor(Theme.textTertiary).padding(.horizontal, 12)
                        Rectangle().fill(Theme.cardBorder).frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)

                    VStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.textSecondary)

                        Button("Sign In") {
                            viewModel.clearFields()
                            dismiss()
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.accentPurple, Theme.accentCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }

                    Spacer().frame(height: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.clearFields()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Theme.accentCyan)
                }
            }
        }
    }
}
