import Foundation

struct FoodPortionHeuristics {
    static let defaultPortions: [String: Double] = [
        "apple": 182.0,
        "banana": 118.0,
        "orange": 154.0,
        "pizza": 110.0,
        "hamburger": 120.0,
        "french fries": 110.0,
        "fried_rice": 140.0,
        "pasta": 140.0,
        "bread": 35.0,
        "rice": 150.0,
        "steak": 150.0,
        "chicken": 120.0,
        "salad": 100.0,
        "donut": 50.0,
        "cake": 100.0,
        "ice_cream": 80.0,
        "sandwich": 120.0,
        "soup": 250.0,
        "sushi": 180.0,
        "tacos": 100.0,
        "egg": 50.0,
        "cheese": 30.0,
        "avocado": 150.0,
        "nuts": 30.0,
        "salmon": 120.0
    ]

    static func defaultWeight(for className: String) -> Double {
        let cleanName = className.replacingOccurrences(of: "_", with: " ").lowercased()

        if let weight = defaultPortions[cleanName] {
            return weight
        }

        for (key, weight) in defaultPortions {
            if cleanName.contains(key) || key.contains(cleanName) {
                return weight
            }
        }

        return 150.0
    }
}
