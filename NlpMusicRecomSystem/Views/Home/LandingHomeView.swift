//
//  LandingHomeView.swift
//  NlpMusicRecomSystem
//
//  The app's main landing screen — introduces the app with a hero banner,
//  CTA buttons to Chat and Discovery, and a "Recommended for You" section.
//

import SwiftUI

struct LandingHomeView: View {

    @Binding var selectedTab: AppTab
    let recommendationService: any RecommendationServiceProtocol
    @ObservedObject var audioPlayer: AudioPlayerViewModel

    @State private var recommendedSongs: [Song] = []
    @State private var isLoading = false

    /// Default neutral 9D mood vector for fetching general recommendations.
    private let defaultMoodVector: [Double] = Array(repeating: 0.5, count: 9)

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Navigation header
                    navigationHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    // Hero section
                    heroSection
                        .padding(.top, 20)

                    // Hero banner (card stack)
                    HeroBannerView()
                        .padding(.top, 8)

                    // CTA buttons
                    ctaButtons
                        .padding(.horizontal, 24)
                        .padding(.top, 32)

                    // Recommended for You section
                    if !recommendedSongs.isEmpty {
                        RecommendedSectionView(
                            songs: recommendedSongs,
                            audioPlayer: audioPlayer
                        )
                        .padding(.top, 36)
                    } else if isLoading {
                        loadingSection
                            .padding(.top, 36)
                    }

                    // Bottom spacing for tab bar
                    Spacer()
                        .frame(height: audioPlayer.currentSong != nil ? 180 : 120)
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
        .task {
            await loadRecommendations()
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        HStack {
            Button {
                selectedTab = .profile
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 0, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            Text("Musaic")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            
        }
        .padding(.vertical, 12)
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 12) {
            Text("AI-Powered Music\nSanctuary")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Text("Discover new sounds curated specifically\nfor your mood and taste by advanced\nartificial intelligence.")
                .font(Theme.subheadlineFont)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - CTA Buttons

    private var ctaButtons: some View {
        VStack(spacing: 14) {
            // Start Discovery button
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = .discovery
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Start Discovery")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Theme.primary)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            // Chat with AI button
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = .chat
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Chat with AI")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(Theme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Theme.primary.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(Theme.primary.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - Loading Section

    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(Theme.primary)
                .scaleEffect(1.1)

            Text("Loading recommendations...")
                .font(Theme.captionFont)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Data Loading

    private func loadRecommendations() async {
        guard recommendedSongs.isEmpty else { return }
        isLoading = true

        do {
            let songs = try await recommendationService.getRecommendations(
                for: defaultMoodVector,
                count: 10
            )
            await MainActor.run {
                recommendedSongs = songs
                isLoading = false
            }
        } catch {
            print("❌ Failed to load home recommendations: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
