//
//  DiscoveryContainerView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct DiscoveryContainerView: View {

    @ObservedObject var viewModel: DiscoveryViewModel
    @ObservedObject var audioPlayer: AudioPlayerViewModel

    var body: some View {
        ZStack {
            GradientBackground()

            Group {
                switch viewModel.state {
                case .moodInput:
                    MoodInputView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .loading:
                    LoadingView()
                        .transition(.opacity)

                case .swipeCards:
                    DiscoverySwipeView(viewModel: viewModel, audioPlayer: audioPlayer)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))

                case .empty:
                    emptyStateView
                        .transition(.opacity)

                case .error(let message):
                    errorView(message: message)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: viewModel.state)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.accentCyan)

            Text("All caught up!")
                .font(Theme.titleFont)
                .foregroundColor(Theme.textPrimary)

            Text("You've swiped through all recommendations.\nTry a new mood!")
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.goBackToMoodInput()
            } label: {
                Text("New Mood")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.backgroundDark)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Theme.accentCyan)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)

            Spacer()
            Spacer()
        }
        .padding()
    }

    // MARK: - Error State

    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.accentPink)

            Text("Something went wrong")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)

            Text(message)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.goBackToMoodInput()
            } label: {
                Text("Try Again")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.backgroundDark)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Theme.accentCyan)
                    .clipShape(Capsule())
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}
