//
//  MoodInputView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct MoodInputView: View {

    @ObservedObject var viewModel: DiscoveryViewModel
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
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
                TextField("", text: $viewModel.moodText,
                          prompt: Text("Type your mood to discover...")
                            .foregroundColor(Theme.textTertiary)
                )
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textPrimary)
                .focused($isTextFieldFocused)
                .submitLabel(.send)
                .onSubmit {
                    Task { await viewModel.analyzeMoodAndFetchSongs() }
                }

                // Arrow button
                Button {
                    isTextFieldFocused = false
                    Task { await viewModel.analyzeMoodAndFetchSongs() }
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(
                            viewModel.moodText.isEmpty
                            ? Theme.textTertiary
                            : Theme.accentCyan
                        )
                        .frame(width: 36, height: 36)
                }
                .disabled(viewModel.moodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            ForEach(viewModel.moodPresets, id: \.self) { preset in
                MoodChipView(title: preset) {
                    viewModel.selectPreset(preset)
                }
            }
        }
    }
}

// MARK: - Flow Layout (Wrapping HStack)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews)
    -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (
            CGSize(width: maxWidth, height: currentY + lineHeight),
            positions
        )
    }
}
