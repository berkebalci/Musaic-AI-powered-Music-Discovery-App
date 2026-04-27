//
//  CardStackView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct CardStackView: View {

    @ObservedObject var viewModel: DiscoveryViewModel

    var body: some View {
        ZStack {
            ForEach(
                Array(viewModel.visibleCards.enumerated().reversed()),
                id: \.element.id
            ) { index, song in
                SwipeCardView(
                    song: song,
                    isTopCard: index == 0,
                    onSwipeLeft: {
                        Task { await viewModel.swipeLeft(on: song) }
                    },
                    onSwipeRight: {
                        Task { await viewModel.swipeRight(on: song) }
                    }
                )
                .zIndex(Double(viewModel.visibleCards.count - index))
                .offset(x: CGFloat(index) * 10, y: CGFloat(index) * -6)
                .scaleEffect(1.0 - CGFloat(index) * 0.05)
                .opacity(1.0 - Double(index) * 0.2)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.cards.count)
            }
        }
    }
}
