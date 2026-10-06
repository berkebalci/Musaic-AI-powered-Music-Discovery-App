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

enum APIError: Error, LocalizedError {
    case networkUnavailable
    case authenticationRequired
    case tooManyRequests(retryAfterSeconds: Int?) // 429 için süre bilgisi
    case httpError(statusCode: Int, data: Data)
    case decodingFailed(Error)
    case invalidResponse
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "İnternet bağlantısı bulunamadı."
        case .authenticationRequired:
            return "Oturum süreniz doldu, lütfen tekrar giriş yapın."
        case .tooManyRequests(let seconds):
            if let seconds = seconds {
                return "Çok fazla istek yapıldı. Lütfen \(seconds) saniye sonra tekrar deneyin."
            }
            return "Çok fazla istek yapıldı. Lütfen biraz bekleyip tekrar deneyin."
        case .httpError(let statusCode, _):
            return "Sunucu hatası oluştu (Kod: \(statusCode))."
        case .decodingFailed:
            return "Gelen veri işlenirken hata oluştu."
        case .invalidResponse, .unknown:
            return "Beklenmeyen bir hata oluştu."
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
        do{
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
            
            if httpResponse.statusCode == 429 {
                var retrySeconds: Int? = nil
                
                // HTTP Header isimleri case-insensitive olabilir, bu yüzden güvenli arama yapılır:
                if let retryHeaderValue = httpResponse.value(forHTTPHeaderField: "Retry-After") {
                    retrySeconds = Int(retryHeaderValue)
                }
                
#if DEBUG
                print("⚠️️ [APIClient] 429 Rate Limited! Retry-After: \(retrySeconds?.description ?? "Yok")")
#endif
                
                throw APIError.tooManyRequests(retryAfterSeconds: retrySeconds)
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
        catch{
            await MainActor.run {
                GlobalErrorManager.shared.handle(error)
            }
            throw error
        }
    }
}
