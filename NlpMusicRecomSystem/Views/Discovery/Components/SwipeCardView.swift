//
//  SwipeCardView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct SwipeCardView: View {

    let song: Song
    let isTopCard: Bool
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void

    @State private var offset: CGSize = .zero
    @State private var isDragging = false

    private let swipeThreshold: CGFloat = 120

    // MARK: - Computed

    private var dragProgress: CGFloat {
        min(abs(offset.width) / swipeThreshold, 1.0)
    }

    private var isSwipingRight: Bool {
        offset.width > 0
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            cardContent

            if isTopCard && isDragging {
                swipeOverlay
            }
        }
        .offset(x: isTopCard ? offset.width : 0,
                y: isTopCard ? offset.height * 0.3 : 0)
        .rotationEffect(.degrees(isTopCard ? Double(offset.width / 25) : 0))
        .gesture(isTopCard ? dragGesture : nil)
    }

    // MARK: - Card Content

    private var cardContent: some View {
        VStack(spacing: 0) {
            AlbumArtPlaceholder(songId: song.id, size: 260, cornerRadius: 16)
                .shadow(color: .black.opacity(0.3), radius: 12, y: 8)
        }
        .padding(20)
        .frame(width: 300, height: 340)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(.ultraThinMaterial)
                .opacity(0.5)
        )
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(Theme.cardGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
    }

    // MARK: - Swipe Overlay

    private var swipeOverlay: some View {
        ZStack {
            if isSwipingRight {
                // Heart overlay (right side)
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)
                    .opacity(Double(dragProgress) * 0.8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding(.trailing, 40)
            } else {
                // X overlay (left side)
                Image(systemName: "xmark")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(Double(dragProgress) * 0.8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.leading, 40)
            }
        }
        .frame(width: 300, height: 340)
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
                isDragging = true
            }
            .onEnded { value in
                isDragging = false
                if value.translation.width > swipeThreshold {
                    performSwipeRight()
                } else if value.translation.width < -swipeThreshold {
                    performSwipeLeft()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        offset = .zero
                    }
                }
            }
    }

    // MARK: - Swipe Actions

    private func performSwipeRight() {
        withAnimation(.easeOut(duration: 0.3)) {
            offset = CGSize(width: 500, height: offset.height)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            offset = .zero
            onSwipeRight()
        }
    }

    private func performSwipeLeft() {
        withAnimation(.easeOut(duration: 0.3)) {
            offset = CGSize(width: -500, height: offset.height)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            offset = .zero
            onSwipeLeft()
        }
    }
}
