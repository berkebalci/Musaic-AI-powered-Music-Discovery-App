//
//  NlpMusicRecomSystemApp.swift
//  NlpMusicRecomSystem
//
//  Created by Berkenin Bilgisayarı on 8.04.2026.
//

import SwiftUI

@main
struct NlpMusicRecomSystemApp: App {

    /// DI container with real API-backed services.
    /// Swap to `.mock()` for UI development without a running server.
    private let container = DIContainer.live()

    var body: some Scene {
        WindowGroup {
            MainTabView(container: container)
                .preferredColorScheme(.dark)
        }
    }
}
