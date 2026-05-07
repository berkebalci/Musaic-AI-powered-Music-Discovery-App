//
//  APIClient.swift
//  NlpMusicRecomSystem
//
//  A lightweight, protocol-oriented networking client built on URLSession.
//  Uses Swift Concurrency (async/await) — Apple's recommended approach.
//

import Foundation

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingFailed(Error)
    case networkUnavailable
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

    init(session: URLSession = .shared) {
        self.session = session

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

        return try await perform(request, responseType: responseType)
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
