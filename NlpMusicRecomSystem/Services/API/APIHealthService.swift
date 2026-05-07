//
//  APIHealthService.swift
//  NlpMusicRecomSystem
//
//  Service to check whether the API backend is reachable and healthy.
//

import Foundation

final class APIHealthService {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    /// Pings the `/health` endpoint to verify the API is running.
    func checkHealth() async -> Bool {
        do {
            let response = try await apiClient.get(
                url: APIEnvironment.healthURL,
                responseType: HealthResponseDTO.self
            )
            return response.isHealthy
        } catch {
            #if DEBUG
            print("[APIHealthService] Health check failed: \(error)")
            #endif
            return false
        }
    }
}
