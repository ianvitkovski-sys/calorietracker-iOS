import Foundation

enum MealType: String, Codable, CaseIterable, Identifiable, Sortable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var id: String { rawValue }

    var sortOrder: Int {
        switch self {
        case .breakfast: return 0
        case .snack: return 1
        case .lunch: return 2
        case .dinner: return 3
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sun.max"
        case .lunch: return "sun.and.horizon"
        case .dinner: return "moon"
        case .snack: return "popcorn"
        }
    }

    var defaultTimeRange: (start: String, end: String) {
        switch self {
        case .breakfast: return ("06:00", "10:00")
        case .lunch: return ("11:00", "14:00")
        case .dinner: return ("17:00", "22:00")
        case .snack: return ("10:00", "16:00")
        }
    }
}

protocol Sortable {
    var sortOrder: Int { get }
}
