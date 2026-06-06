//
//  HomeView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

/// Home tab view — contains the mood input UI (previously in Discovery)
/// and navigates to the AI mood chat screen.
struct HomeView: View {

    @ObservedObject var chatViewModel: ChatViewModel
    @State private var moodText: String = ""
    @State private var showChat: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    private let moodPresets = [
        "Midnight drive",
        "Energetic & focused",
        "Mellow rainy day",
        "Sunday chill vibes",
        "Feeling sad today",
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 60)

                        // Sparkle icon
                        AnimatedSparkle()
                            .frame(height: 80)
                            .padding(.bottom, 24)

                        // Title
                        Text("Mood Discovery")
                            .font(Theme.titleFont)
                            .foregroundColor(Theme.textPrimary)
                            .padding(.bottom, 8)

                        // Subtitle
                        Text("AI-curated soundtracks for your emotions")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.textSecondary)
                            .padding(.bottom, 40)

                        // Mood Input Card
                        moodInputCard
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)

                        // Mood Presets
                        moodPresetChips
                            .padding(.horizontal, 24)

                        Spacer()
                            .frame(height: 120)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationDestination(isPresented: $showChat) {
                MoodChatView(viewModel: chatViewModel)
            }
        }
    }

    // MARK: - Mood Input Card

    private var moodInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR VIBE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Theme.accentCyan)
                .tracking(1.5)

            Text("How are you feeling?")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textPrimary)

            Spacer()
                .frame(height: 20)

            // Text field with send button
            HStack(spacing: 8) {
                TextField("", text: $moodText,
                          prompt: Text("Type your mood to discover...")
                            .foregroundColor(Theme.textTertiary)
                )
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textPrimary)
                .focused($isTextFieldFocused)
                .submitLabel(.send)
                .onSubmit {
                    navigateToChat()
                }

                // Arrow button
                Button {
                    isTextFieldFocused = false
                    navigateToChat()
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(
                            moodText.isEmpty
                            ? Theme.textTertiary
                            : Theme.accentCyan
                        )
                        .frame(width: 36, height: 36)
                }
                .disabled(moodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            // Bottom divider
            Rectangle()
                .fill(Theme.cardBorder)
                .frame(height: 1)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(.ultraThinMaterial)
                .opacity(0.4)
        )
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(Theme.cardSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Mood Preset Chips

    private var moodPresetChips: some View {
        FlowLayout(spacing: 10) {
            ForEach(moodPresets, id: \.self) { preset in
                MoodChipView(title: preset) {
                    moodText = preset
                    navigateToChat()
                }
            }
        }
    }

    // MARK: - Navigation

    private func navigateToChat() {
        let text = moodText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        chatViewModel.startWithMood(text)
        moodText = ""
        showChat = true
    }
}
