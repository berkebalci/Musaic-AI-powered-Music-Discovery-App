//
//  HealthResponseDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /health endpoint response.
//

import Foundation

/// Response from `GET /health`.
struct HealthResponseDTO: Decodable {
    let status: String
    let apiSecure: Bool?

    var isHealthy: Bool {
        status == "ok"
    }
}
