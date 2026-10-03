import SwiftData
import Foundation
import SwiftUI

@Model
final class FoodItemInMeal {
    @Attribute(.unique) var id: UUID
    var mealLogId: UUID
    var foodDatabaseId: String
    var foodName: String
    var estimatedWeightG: Double
    var userAdjustedWeightG: Double?
    var calories: Double
    var proteinG: Double
    var carbsG: Double
    var fatG: Double
    var fiberG: Double
    var sugarG: Double
    var sodiumMg: Double
    var vitaminCMg: Double
    var vitaminA: Double
    var calciumMg: Double
    var ironMg: Double
    var detectionConfidence: Double?
    var userConfirmed: Bool
    var notes: String?

    init(
        id: UUID = UUID(),
        mealLogId: UUID,
        foodDatabaseId: String,
        foodName: String,
        estimatedWeightG: Double,
        userAdjustedWeightG: Double? = nil,
        calories: Double,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        fiberG: Double = 0,
        sugarG: Double = 0,
        sodiumMg: Double = 0,
        vitaminCMg: Double = 0,
        vitaminA: Double = 0,
        calciumMg: Double = 0,
        ironMg: Double = 0,
        detectionConfidence: Double? = nil,
        userConfirmed: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.mealLogId = mealLogId
        self.foodDatabaseId = foodDatabaseId
        self.foodName = foodName
        self.estimatedWeightG = estimatedWeightG
        self.userAdjustedWeightG = userAdjustedWeightG
        self.calories = calories
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.fiberG = fiberG
        self.sugarG = sugarG
        self.sodiumMg = sodiumMg
        self.vitaminCMg = vitaminCMg
        self.vitaminA = vitaminA
        self.calciumMg = calciumMg
        self.ironMg = ironMg
        self.detectionConfidence = detectionConfidence
        self.userConfirmed = userConfirmed
        self.notes = notes
    }

    var finalWeightG: Double {
        userAdjustedWeightG ?? estimatedWeightG
    }

    var confidenceText: String {
        guard let confidence = detectionConfidence else { return "Manual" }
        return "\(Int(confidence * 100))%"
    }

    var confidenceColor: Color {
        guard let confidence = detectionConfidence else { return .secondary }
        switch confidence {
        case 0.8...1.0: return Color(UIColor.systemGreen)
        case 0.5..<0.8: return Color(UIColor.systemOrange)
        default: return Color(UIColor.systemRed)
        }
    }
}
