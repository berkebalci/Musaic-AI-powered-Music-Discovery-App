//
//  NlpMusicRecomSystemApp.swift
//  NlpMusicRecomSystem
//
//  Created by Berkenin Bilgisayarı on 8.04.2026.
//

import SwiftUI
import FirebaseCore

@main
struct NlpMusicRecomSystemApp: App {

    /// DI container with real API-backed services.
    /// Swap to `.mock()` for UI development without a running server.
    private let container: DIContainer

    init() {
        // Firebase MUST be configured before any Firebase service is used
        FirebaseApp.configure()
        container = DIContainer.live()
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .preferredColorScheme(.dark)
        }
    }
}
