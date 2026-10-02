import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case statusCode(Int)
    case decodingFailed
    case noData
    case unauthorized
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .requestFailed(let error): return "Request failed: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid server response"
        case .statusCode(let code): return "Server error: \(code)"
        case .decodingFailed: return "Failed to decode response"
        case .noData: return "No data received"
        case .unauthorized: return "Authentication required"
        case .rateLimited: return "Too many requests, please try again later"
        }
    }

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingFailed, .decodingFailed),
             (.noData, .noData),
             (.unauthorized, .unauthorized),
             (.rateLimited, .rateLimited):
            return true
        case (.statusCode(let lhsCode), .statusCode(let rhsCode)):
            return lhsCode == rhsCode
        case (.requestFailed, .requestFailed):
            return true
        default:
            return false
        }
    }
}

enum NetworkError: LocalizedError {
    case noInternet
    case timeout
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .noInternet: return "No internet connection"
        case .timeout: return "Request timed out"
        case .serverError(let msg): return "Server error: \(msg)"
        }
    }
}
