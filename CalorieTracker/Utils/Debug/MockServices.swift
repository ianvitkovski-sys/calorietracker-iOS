import Foundation
import SwiftData
import UIKit

@MainActor
struct MockFoodDetectionService {
    func detectFood(in image: UIImage) async -> [DetectedFood] {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        return PreviewData.sampleDetectedFoods
    }
}

@MainActor
struct MockNutritionLookupService {
    func lookupNutrition(for foodName: String, weightGrams: Double) async throws -> FoodItemInMeal? {
        try? await Task.sleep(nanoseconds: 500_000_000)

        let ratio = weightGrams / 100.0
        return FoodItemInMeal(
            mealLogId: UUID(),
            foodDatabaseId: "06008",
            foodName: foodName,
            estimatedWeightG: weightGrams,
            calories: 250 * ratio,
            proteinG: 20 * ratio,
            carbsG: 17 * ratio,
            fatG: 10 * ratio,
            userConfirmed: false
        )
    }
}
