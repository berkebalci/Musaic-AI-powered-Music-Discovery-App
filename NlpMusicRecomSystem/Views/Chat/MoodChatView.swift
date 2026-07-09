//
//  MoodChatView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

/// The AI mood chat screen — a conversational interface
/// where the user describes their mood and receives song recommendations.
struct MoodChatView: View {

    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var audioPlayer: AudioPlayerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Deep gradient background
            chatBackground

            VStack(spacing: 0) {
                // Messages scroll area
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            Spacer()
                                .frame(height: 16)

                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message, audioPlayer: audioPlayer)
                                    .id(message.id)

                                // Show mood presets after the first AI greeting
                                if message == viewModel.messages.first && !message.isFromUser {
                                    moodPresetChips
                                        .padding(.horizontal, 16)
                                        .padding(.top, 4)
                                }
                            }

                            // Status text (e.g., "Curating a temporary playlist...")
                            if let status = viewModel.statusText {
                                HStack {
                                    Text(status)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Theme.primary)
                                        .italic()
                                    Spacer()
                                }
                                .padding(.horizontal, 32)
                                .padding(.top, 4)
                                .transition(.opacity)
                            }

                            // Extra space at bottom so content doesn't hide behind mini player
                            Spacer()
                                .frame(height: audioPlayer.currentSong != nil ? 80 : 16)
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastId = viewModel.messages.last?.id {
                            withAnimation(.easeOut(duration: 0.3)) {
                                scrollProxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }

                // Mini Player (above input bar)
                if audioPlayer.currentSong != nil {
                    MiniPlayerView(audioPlayer: audioPlayer)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 4)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Input bar
                ChatInputBarView(
                    text: $viewModel.inputText,
                    isDisabled: viewModel.isAITyping,
                    onSend: {
                        Task { await viewModel.sendMessage() }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: audioPlayer.currentSong != nil)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Theme.secondaryBg)
                            .frame(width: 36, height: 36)

                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Mood Chat")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Chat Background

    private var chatBackground: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Theme.background,
                    Theme.backgroundPrimary,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Mood Preset Chips

    private var moodPresetChips: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.moodPresets, id: \.self) { preset in
                MoodChipView(title: preset) {
                    viewModel.selectPreset(preset)
                }
            }
        }
    }
}
