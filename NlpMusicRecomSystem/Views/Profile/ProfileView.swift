//
//  ProfileView.swift
//  NlpMusicRecomSystem
//
//  Shows the signed-in user's display name / email, their favorite songs
//  in a horizontal row, and the Sign Out action.
//  Favorites come from the shared `FavoritesViewModel` cache, so opening this
//  tab does not hit the API unless a new song was liked since the last load.
//

import SwiftUI
import Combine

struct ProfileView: View {

    let authService: any AuthServiceProtocol
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @ObservedObject var audioPlayer: AudioPlayerViewModel

    @State private var user: AuthUser?
    @State private var showSignOutAlert = false

    init(
        authService: any AuthServiceProtocol,
        favoritesViewModel: FavoritesViewModel,
        audioPlayer: AudioPlayerViewModel
    ) {
        self.authService = authService
        self.favoritesViewModel = favoritesViewModel
        self.audioPlayer = audioPlayer
        _user = State(initialValue: authService.currentUser)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    profileHeader
                        .padding(.top, 32)

                    favoritesSection

                    signOutButton
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                    legalLinks

                    deleteAccountButton
                        .padding(.horizontal, 24)

                    // Bottom spacing for tab bar / mini player
                    Spacer()
                        .frame(height: audioPlayer.currentSong != nil ? 160 : 100)
                }
            }

            // Mini Player
            if audioPlayer.currentSong != nil {
                MiniPlayerView(audioPlayer: audioPlayer)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: audioPlayer.currentSong != nil)
        // Keeps the name in sync (Apple's full name is written right after sign-in).
        .onReceive(authService.currentUserPublisher.receive(on: DispatchQueue.main)) { user = $0 }
        // No-op unless favorites were never loaded or a like was synced since.
        .task { await favoritesViewModel.loadFavoritesIfNeeded() }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                audioPlayer.stop()
                try? authService.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    // MARK: - Header

    private var displayName: String {
        if let name = user?.displayName, !name.trimmingCharacters(in: .whitespaces).isEmpty {
            return name
        }
        return "Your Profile"
    }

    private var profileHeader: some View {
        VStack(spacing: 14) {
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

            VStack(spacing: 6) {
                Text(displayName)
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                if let email = user?.email {
                    Text(email)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Favorites

    @ViewBuilder
    private var favoritesSection: some View {
        if !favoritesViewModel.favorites.isEmpty {
            RecommendedSectionView(
                songs: favoritesViewModel.favorites,
                audioPlayer: audioPlayer,
                title: "Your Favorites",
                limit: 20
            )
        } else if favoritesViewModel.isLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(Theme.primary)
                Text("Loading favorites...")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "heart.slash")
                    .font(.system(size: 28))
                    .foregroundColor(Theme.textTertiary)
                Text("No favorites yet")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
                Text("Like songs in Discovery to see them here")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
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
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Legal Links

    private var legalLinks: some View {
        HStack(spacing: 8) {
            Link("Gizlilik Politikası", destination: AppLinks.privacyPolicy)

            Text("•")
                .foregroundColor(Theme.textTertiary)

            Link("Kullanım Koşulları", destination: AppLinks.termsOfUse)
        }
        .font(Theme.captionFont)
        .foregroundColor(Theme.textSecondary)
    }

    // MARK: - Delete Account

    /// UI only — account deletion logic is not implemented yet.
    private var deleteAccountButton: some View {
        Button {
            // TODO: Implement account deletion (Firebase user delete + Apple token revoke).
        } label: {
            Text("Hesabı Sil")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#FF6B6B").opacity(0.8))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
