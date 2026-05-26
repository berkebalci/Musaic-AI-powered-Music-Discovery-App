//
//  NlpMusicRecomSystemApp.swift
//  NlpMusicRecomSystem
//
//  Created by Berkenin Bilgisayarı on 8.04.2026.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct NlpMusicRecomSystemApp: App {

    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

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

