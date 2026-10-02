import Foundation

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary = "Sedentary"
    case light = "Light"
    case moderate = "Moderate"
    case active = "Active"
    case veryActive = "Very Active"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .sedentary: return "Little or no exercise"
        case .light: return "Light exercise, 1-3 days/week"
        case .moderate: return "Moderate exercise, 3-5 days/week"
        case .active: return "Hard exercise, 6-7 days/week"
        case .veryActive: return "Very hard exercise, physical job"
        }
    }

    var bmrMultiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}
