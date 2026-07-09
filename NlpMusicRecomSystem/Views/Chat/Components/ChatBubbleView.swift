//
//  ChatBubbleView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct ChatBubbleView: View {

    let message: ChatMessage
    @ObservedObject var audioPlayer: AudioPlayerViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if message.isFromUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 8) {
                // Loading indicator
                if message.isLoading {
                    typingIndicator
                } else {
                    // Message text
                    Text(message.content)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Embedded song cards (AI messages only)
                    if !message.suggestedSongs.isEmpty {
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(spacing: 8) {
                                ForEach(message.suggestedSongs) { song in
                                    ChatSongCardView(song: song, audioPlayer: audioPlayer)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(maxHeight: 260)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(bubbleBackground)
            .overlay(bubbleOverlay)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Bubble Background

    @ViewBuilder
    private var bubbleBackground: some View {
        if message.isFromUser {
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.primary.opacity(0.15))
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.secondaryBg)
        }
    }

    // MARK: - Bubble Overlay

    @ViewBuilder
    private var bubbleOverlay: some View {
        if message.isFromUser {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.primary.opacity(0.3), lineWidth: 1)
        } else {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.cardBorder, lineWidth: 1)
        }
    }

    // MARK: - Typing Indicator

    private var typingIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                TypingDot(delay: Double(index) * 0.2)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
}

// MARK: - Typing Dot Animation

private struct TypingDot: View {
    let delay: Double
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(Theme.textSecondary)
            .frame(width: 8, height: 8)
            .offset(y: isAnimating ? -4 : 2)
            .animation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
