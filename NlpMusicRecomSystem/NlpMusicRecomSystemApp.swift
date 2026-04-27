//
//  NlpMusicRecomSystemApp.swift
//  NlpMusicRecomSystem
//
//  Created by Berkenin Bilgisayarı on 8.04.2026.
//

import SwiftUI

@main
struct NlpMusicRecomSystemApp: App {

    /// DI container with mock services for development.
    /// Swap to `.live()` when real APIs are integrated.
    private let container = DIContainer.mock()

    var body: some Scene {
        WindowGroup {
            MainTabView(container: container)
                .preferredColorScheme(.dark)
        }
    }
}
