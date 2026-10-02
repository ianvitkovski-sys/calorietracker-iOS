import Foundation

@MainActor
final class USDAService {
    static let shared = USDAService()

    private let baseURL = "https://api.nal.usda.gov/fdc/v1/"
    private let session: URLSession
    private let apiKey: String

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)
        apiKey = Bundle.main.object(forInfoDictionaryKey: "USDA_API_KEY") as? String ?? ""
    }

    func searchFood(query: String) async throws -> Int? {
        var components = URLComponents(string: "\(baseURL)foods/search")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "pageSize", value: "5"),
            URLQueryItem(name: "dataType", value: "Survey%20(FNDDS%20Basis)")
        ]

        guard let url = components.url else { throw USDError.networkError(NSError()) }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw USDError.networkError(NSError())
        }

        let searchResponse = try JSONDecoder().decode(USDASearchResponse.self, from: data)

        guard let firstResult = searchResponse.foods.first else {
            throw USDError.foodNotFound
        }

        return firstResult.fdcId
    }

    func getFoodDetails(fdcId: Int, nutrients: String? = nil) async throws -> USDAFoodResponse {
        var components = URLComponents(string: "\(baseURL)food/\(fdcId)")!
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "api_key", value: apiKey)]
        if let nutrients = nutrients {
            queryItems.append(URLQueryItem(name: "nutrients", value: nutrients))
        }
        components.queryItems = queryItems

        guard let url = components.url else { throw USDError.networkError(NSError()) }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw USDError.networkError(NSError())
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(USDAFoodResponse.self, from: data)
    }

    func getFoodListnutrients(fdcId: Int) async throws -> USDAFoodResponse {
        var components = URLComponents(string: "\(baseURL)food/\(fdcId)")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "nutrients", value: "1008,1003,1005,1004,10795,10121,10925,1087,1089,1106,1051,1107,1108,1114")
        ]

        return try await getFoodDetails(fdcId: fdcId, nutrients: "1008,1003,1005,1004,10795,10121,1087,1089,1106,1051,1107,1108,1114")
    }
}
