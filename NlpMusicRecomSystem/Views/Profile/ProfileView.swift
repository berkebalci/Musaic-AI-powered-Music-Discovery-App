//
//  ProfileView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Theme.cardSurface)
                        .frame(width: 100, height: 100)

                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Theme.accentCyan.opacity(0.6))
                }

                Text("Profile")
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)

                Text("Coming soon")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)

                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}
