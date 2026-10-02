import Foundation

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case other = "Other"

    var id: String { rawValue }

    var pronoun: String {
        switch self {
        case .male: return "he"
        case .female: return "she"
        case .other: return "they"
        }
    }
}
