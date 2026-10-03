import Foundation

/// Response model for `GET /fdc/v1/foods/search`.
struct USDASearchResponse: Decodable {
    let foods: [USDAFoodSummary]

    enum CodingKeys: String, CodingKey {
        case foods
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        foods = try container.decodeIfPresent([USDAFoodSummary].self, forKey: .foods) ?? []
    }
}

/// A single food hit from the USDA search endpoint.
struct USDAFoodSummary: Decodable, Identifiable {
    let fdcId: Int
    let description: String
    let foodCategory: String

    var id: Int { fdcId }

    enum CodingKeys: String, CodingKey {
        case fdcId
        case description
        case foodCategory
    }

    init(fdcId: Int, description: String, foodCategory: String) {
        self.fdcId = fdcId
        self.description = description
        self.foodCategory = foodCategory
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fdcId = try container.decode(Int.self, forKey: .fdcId)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? "Unknown food"
        foodCategory = try container.decodeIfPresent(String.self, forKey: .foodCategory) ?? ""
    }
}

/// Response model for `GET /fdc/v1/food/{fdcId}`.
///
/// The API returns the nutrient array under `foodNutrients`; it is surfaced here as `nutrients`.
struct USDAFoodResponse: Decodable {
    let fdcId: Int?
    let description: String
    let foodCategory: String
    let nutrients: [USDANutrient]

    enum CodingKeys: String, CodingKey {
        case fdcId
        case description
        case foodCategory
        case nutrients = "foodNutrients"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fdcId = try container.decodeIfPresent(Int.self, forKey: .fdcId)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? "Unknown food"
        foodCategory = try container.decodeIfPresent(String.self, forKey: .foodCategory) ?? ""
        nutrients = try container.decodeIfPresent([USDANutrient].self, forKey: .nutrients) ?? []
    }
}

/// A single nutrient entry within a USDA food response.
struct USDANutrient: Decodable, Identifiable {
    let nutrientId: Int?
    let name: String
    let amount: Double
    let unitName: String?

    var id: String { "\(nutrientId ?? 0)-\(name)" }

    enum CodingKeys: String, CodingKey {
        case nutrientId
        case name
        case amount
        case unitName
    }

    init(nutrientId: Int?, name: String, amount: Double, unitName: String? = nil) {
        self.nutrientId = nutrientId
        self.name = name
        self.amount = amount
        self.unitName = unitName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nutrientId = try container.decodeIfPresent(Int.self, forKey: .nutrientId)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0
        unitName = try container.decodeIfPresent(String.self, forKey: .unitName)
    }
}