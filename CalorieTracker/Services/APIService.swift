import Foundation
import UIKit

@MainActor
final class APIService {
    static let shared = APIService()

    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)

        jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601

        jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(
        url: URL,
        method: String = "GET",
        parameters: [String: String]? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        if let params = parameters {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let requestURL = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers ?? [:]

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimited
        case 400...599:
            throw APIError.statusCode(httpResponse.statusCode)
        default:
            throw APIError.invalidResponse
        }

        guard !data.isEmpty else {
            throw APIError.noData
        }

        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    func requestNoResponse(
        url: URL,
        method: String = "POST",
        body: Data? = nil,
        headers: [String: String]? = nil
    ) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers ?? [:]
        request.httpBody = body

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimited
        case 400...599:
            throw APIError.statusCode(httpResponse.statusCode)
        default:
            throw APIError.invalidResponse
        }
    }

    func encode<T: Encodable>(_ value: T) throws -> Data {
        return try jsonEncoder.encode(value)
    }
}
