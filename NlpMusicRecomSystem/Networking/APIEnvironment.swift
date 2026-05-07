//
//  APIEnvironment.swift
//  NlpMusicRecomSystem
//
//  Reads API configuration from the app's Info.plist,
//  which pulls values from the Secrets.xcconfig build configuration file.
//  This follows Apple's recommended approach for keeping secrets out of source code.
//

import Foundation

enum APIEnvironment {

    // MARK: - Base URL

    /// The base URL for the recommendation API.
    /// Loaded from `Info.plist` → `API_BASE_URL`, which is injected via `Secrets.xcconfig`.
    static var baseURL: URL {
        guard
            let urlString = Bundle.main.infoDictionary?["API_BASE_URL"] as? String,
            let url = URL(string: urlString)
        else {
            fatalError(
                """
                ⚠️ API_BASE_URL is not configured.
                
                Make sure:
                1. Secrets.xcconfig exists in Configuration/ with API_BASE_URL set.
                2. The xcconfig is linked to your build configuration in the Xcode project.
                3. Info.plist contains: API_BASE_URL = $(API_BASE_URL)
                """
            )
        }
        return url
    }

    // MARK: - Endpoints

    /// POST /recommend
    static var recommendURL: URL {
        baseURL.appendingPathComponent("recommend")
    }

    /// POST /swipe
    static var swipeURL: URL {
        baseURL.appendingPathComponent("swipe")
    }

    /// GET /health
    static var healthURL: URL {
        baseURL.appendingPathComponent("health")
    }

    /// POST /chat
    static var chatURL: URL {
        baseURL.appendingPathComponent("chat")
    }
}
