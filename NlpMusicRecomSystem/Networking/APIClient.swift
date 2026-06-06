//
//  APIClient.swift
//  NlpMusicRecomSystem
//
//  A lightweight, protocol-oriented networking client built on URLSession.
//  Uses Swift Concurrency (async/await) — Apple's recommended approach.
//  Supports Firebase ID token authentication via a token provider closure.
//

import Foundation

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingFailed(Error)
    case networkUnavailable
    case authenticationRequired
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Sunucudan geçersiz bir yanıt alındı."
        case .httpError(let code, _):
            return "Sunucu hatası (HTTP \(code))."
        case .decodingFailed:
            return "Sunucu yanıtı okunamadı."
        case .networkUnavailable:
            return "İnternet bağlantınızı kontrol edin."
        case .authenticationRequired:
            return "Oturum açmanız gerekiyor."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - API Client Protocol

protocol APIClientProtocol {
    func post<Request: Encodable, Response: Decodable>(
        url: URL,
        body: Request,
        responseType: Response.Type
    ) async throws -> Response

    func get<Response: Decodable>(
        url: URL,
        responseType: Response.Type
    ) async throws -> Response
}

// MARK: - URLSession-based API Client

final class APIClient: APIClientProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// Closure that provides a fresh Firebase ID token for authenticated requests.
    /// Set this to `nil` for unauthenticated endpoints (e.g., /health).
    private let authTokenProvider: (() async throws -> String)?

    init(
        session: URLSession = .shared,
        authTokenProvider: (() async throws -> String)? = nil
    ) {
        self.session = session
        self.authTokenProvider = authTokenProvider

        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - POST

    func post<Request: Encodable, Response: Decodable>(
        url: URL,
        body: Request,
        responseType: Response.Type
    ) async throws -> Response {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        // Timeout configuration
        request.timeoutInterval = 30

        // Attach auth token if provider is available
        try await attachAuthToken(to: &request)

        return try await perform(request, responseType: responseType)
    }

    // MARK: - GET

    func get<Response: Decodable>(
        url: URL,
        responseType: Response.Type
    ) async throws -> Response {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        // Attach auth token if provider is available
        try await attachAuthToken(to: &request)

        return try await perform(request, responseType: responseType)
    }

    // MARK: - Auth Token

    private func attachAuthToken(to request: inout URLRequest) async throws {
        guard let provider = authTokenProvider else {
            print("⚠️ [APIClient] No auth token provider configured")
            return
        }
        do {
            let token = try await provider()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } catch {
            print("❌ [APIClient] Failed to get auth token: \(error)")
            throw error
        }
    }

    // MARK: - Core Request Execution

    private func perform<Response: Decodable>(
        _ request: URLRequest,
        responseType: Response.Type
    ) async throws -> Response {
        let data: Data
        let urlResponse: URLResponse

        do {
            (data, urlResponse) = try await session.data(for: request)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw APIError.networkUnavailable
        } catch {
            throw APIError.unknown(error)
        }

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle 401/403 as authentication errors
        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            let responseBody = String(data: data, encoding: .utf8) ?? "No body"
            print("❌ [APIClient] Server rejected auth. Status: \(httpResponse.statusCode)")
            print("❌ [APIClient] Response body: \(responseBody)")
            print("❌ [APIClient] Request URL was: \(request.url?.absoluteString ?? "Unknown URL")")
            throw APIError.authenticationRequired
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(responseType, from: data)
        } catch {
            #if DEBUG
            if let raw = String(data: data, encoding: .utf8) {
                print("[APIClient] Decode error for \(responseType): \(error)")
                print("[APIClient] Raw response: \(raw)")
            }
            #endif
            throw APIError.decodingFailed(error)
        }
    }
}
