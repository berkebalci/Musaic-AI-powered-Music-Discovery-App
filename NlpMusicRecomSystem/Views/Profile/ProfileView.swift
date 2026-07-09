//
//  ProfileView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct ProfileView: View {

    let authService: any AuthServiceProtocol
    @State private var showSignOutAlert = false

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 28) {
                Spacer()

                // Avatar
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.12))
                        .frame(width: 110, height: 110)
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.primary, Theme.accentPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text("Your Profile")
                        .font(Theme.titleFont)
                        .foregroundColor(Theme.textPrimary)

                    if let email = authService.currentUser?.email {
                        Text(email)
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                Spacer()

                // Sign Out Button
                Button {
                    showSignOutAlert = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "#FF6B6B"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .fill(Color(hex: "#FF6B6B").opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                    .stroke(Color(hex: "#FF6B6B").opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120) // Tab bar'ın arkasında kalmaması için padding artırıldı
            }
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                try? authService.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}
