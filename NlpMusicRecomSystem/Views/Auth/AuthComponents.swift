//
//  AuthComponents.swift
//  NlpMusicRecomSystem
//
//  Shared UI building blocks used by LoginView and SignUpView.
//

import SwiftUI

// MARK: - AuthTextField

/// A styled text/secure field with a leading SF Symbol icon.
struct AuthTextField: View {

    let icon: String
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let isSecure: Bool

    @State private var isRevealed: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Theme.accentCyan.opacity(0.8))
                .frame(width: 22)

            Group {
                if isSecure && !isRevealed {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .autocapitalization(keyboardType == .emailAddress ? .none : .sentences)
                        .autocorrectionDisabled(keyboardType == .emailAddress)
                }
            }
            .font(Theme.bodyFont)
            .foregroundColor(Theme.textPrimary)

            if isSecure {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textTertiary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Theme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.cardBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - ErrorBanner

/// A red-tinted inline banner for displaying auth error messages.
struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(Color(hex: "#FF6B6B"))
            Text(message)
                .font(Theme.captionFont)
                .foregroundColor(Color(hex: "#FF6B6B"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#FF6B6B").opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#FF6B6B").opacity(0.25), lineWidth: 1)
                )
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.4), value: message)
    }
}
