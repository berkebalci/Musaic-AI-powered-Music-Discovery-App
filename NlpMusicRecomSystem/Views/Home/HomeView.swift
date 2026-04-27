//
//  HomeView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "music.note.house.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.accentCyan.opacity(0.6))

                Text("Welcome to MoodTune")
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)

                Text("Head to Discovery to find\nmusic that matches your mood")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)

                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}
