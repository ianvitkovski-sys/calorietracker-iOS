import Foundation

enum DietaryGoal: String, Codable, CaseIterable, Identifiable {
    case weightLoss = "Weight Loss"
    case maintenance = "Maintenance"
    case muscleGain = "Muscle Gain"
    case keto = "Keto"
    case lowCarb = "Low Carb"

    var id: String { rawValue }

    var calorieAdjustment: Double {
        switch self {
        case .weightLoss: return -500
        case .maintenance: return 0
        case .muscleGain: return 300
        case .keto: return -200
        case .lowCarb: return -300
        }
    }

    var defaultMacroRatio: (protein: Double, carbs: Double, fat: Double) {
        switch self {
        case .weightLoss: return (0.30, 0.40, 0.30)
        case .maintenance: return (0.25, 0.45, 0.30)
        case .muscleGain: return (0.30, 0.40, 0.30)
        case .keto: return (0.20, 0.10, 0.70)
        case .lowCarb: return (0.30, 0.25, 0.45)
        }
    }

    var icon: String {
        switch self {
        case .weightLoss: return "flame"
        case .maintenance: return "scalemass"
        case .muscleGain: return "dumbbell"
        case .keto: return "drop.halffull"
        case .lowCarb: return "chart.line.downtrend.xyaxis"
        }
    }
}
