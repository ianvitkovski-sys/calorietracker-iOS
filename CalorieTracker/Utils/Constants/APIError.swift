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

enum USDError: LocalizedError {
    case networkError(NSError)
    case foodNotFound
    case invalidAPIKey
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .networkError(let error): return "Food database request failed: \(error.localizedDescription)"
        case .foodNotFound: return "No matching food found in the USDA database"
        case .invalidAPIKey: return "USDA API key is missing or invalid"
        case .decodingFailed: return "Could not read the food database response"
        }
    }
}

enum DetectionError: LocalizedError {
    case invalidImage
    case modelNotLoaded
    case processingFailed(Error)
    case noFoodFound

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "The selected image could not be read"
        case .modelNotLoaded: return "The food detection model is not available"
        case .processingFailed(let error): return "Food detection failed: \(error.localizedDescription)"
        case .noFoodFound: return "No food was detected in this photo"
        }
    }
}
