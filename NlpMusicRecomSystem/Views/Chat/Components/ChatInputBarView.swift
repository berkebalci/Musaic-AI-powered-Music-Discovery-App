//
//  ChatInputBarView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

/// Input bar pinned at the bottom of the chat screen.
struct ChatInputBarView: View {

    @Binding var text: String
    let isDisabled: Bool
    let onSend: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            TextField("", text: $text,
                      prompt: Text("Describe your vibe...")
                        .foregroundColor(Theme.textTertiary)
            )
            .font(Theme.bodyFont)
            .foregroundColor(Theme.textPrimary)
            .focused($isFocused)
            .submitLabel(.send)
            .onSubmit { onSend() }
            .disabled(isDisabled)

            // Send button
            Button {
                isFocused = false
                onSend()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Theme.tertiaryBg
                            : Theme.primary
                        )
                        .frame(width: 36, height: 36)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(
                            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Theme.textTertiary
                            : .white
                        )
                }
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isDisabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(inputBarBackground)
    }

    // MARK: - Background

    private var inputBarBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Theme.secondaryBg)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isFocused ? Theme.primary.opacity(0.5) : Theme.cardBorder,
                        lineWidth: 1
                    )
            )
    }
}
