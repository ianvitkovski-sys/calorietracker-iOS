import Foundation
import SwiftUI

@MainActor
final class MealResultsViewModel: ObservableObject {
    @Published var detectedFoods: [DetectedFood]
    @Published var image: UIImage
    @Published var foodItems: [FoodItemInMeal] = []
    @Published var weightEstimates: [String: WeightEstimate] = [:]
    @Published var isCalculatingWeights = false
    @Published var isLookingUpNutrition = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var showError = false

    weak var container: AppContainer?
    private let weightEstimationService: WeightEstimationService
    private let nutritionLookupService: NutritionLookupService

    init(
        container: AppContainer,
        detectedFoods: [DetectedFood],
        image: UIImage
    ) {
        self.container = container
        self.detectedFoods = detectedFoods
        self.image = image
        self.weightEstimationService = container.weightEstimationService
        self.nutritionLookupService = container.nutritionLookupService as! NutritionLookupService

        Task {
            await estimateWeights()
            await lookupNutrition()
        }
    }

    func estimateWeights() async {
        isCalculatingWeights = true
        defer { isCalculatingWeights = false }

        let imageSize = image.size

        for food in detectedFoods {
            let estimate = await weightEstimationService.estimateWeight(
                for: food,
                image: image,
                imageSize: imageSize
            )
            weightEstimates[food.id.uuidString] = estimate
        }
    }

    func lookupNutrition() async {
        isLookingUpNutrition = true
        defer { isLookingUpNutrition = false }

        for food in detectedFoods {
            let weight = weightEstimates[food.id.uuidString]?.estimatedGrams ?? 150.0
            do {
                if let item = try await nutritionLookupService.lookupNutrition(
                    for: food.className,
                    weightGrams: weight
                ) {
                    var newItem = item
                    newItem.detectionConfidence = food.confidence
                    newItem.estimatedWeightG = weight
                    foodItems.append(newItem)
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    func updateWeight(for foodId: String, newWeight: Double) {
        guard let food = detectedFoods.first(where: { $0.id.uuidString == foodId }) else { return }

        let existingEstimate = weightEstimates[foodId] ?? WeightEstimate(
            foodName: food.className,
            estimatedGrams: newWeight,
            confidence: 0.5,
            method: .userDefined,
            userAdjusted: true
        )

        weightEstimates[foodId] = WeightEstimate(
            foodName: existingEstimate.foodName,
            estimatedGrams: newWeight,
            confidence: existingEstimate.confidence,
            method: .userDefined,
            userAdjusted: true
        )
    }

    func totalNutrition() -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        foodItems.reduce((0, 0, 0, 0)) { result, item in
            (
                result.calories + item.calories,
                result.protein + item.proteinG,
                result.carbs + item.carbsG,
                result.fat + item.fatG
            )
        }
    }

    func saveMeal(mealType: MealType, notes: String?) async -> Bool {
        isSaving = true
        defer { isSaving = false }

        guard let user = container?.currentUser else { return false }

        for item in foodItems {
            item.mealLogId = UUID()
            item.userConfirmed = true
        }

        let totals = totalNutrition()
        let mealLog = MealLog(
            userId: user.id,
            timestamp: Date(),
            mealType: mealType,
            imagePath: nil,
            notes: notes,
            items: foodItems,
            totalCalories: totals.calories,
            totalProteinG: totals.protein,
            totalCarbsG: totals.carbs,
            totalFatG: totals.fat
        )

        do {
            try await DataManager.shared.saveMealLog(mealLog)

            let imagePath: String? = nil
            if let imageData = image.jpegData(compressionQuality: 0.85) {
                let filename = "meal_\(UUID().uuidString).jpg"
                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = docs.appendingPathComponent(filename)
                try? imageData.write(to: fileURL)
                imagePath = filename
            }

            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            return false
        }
    }

    func addManualItem(name: String, grams: Double) async {
        isLookingUpNutrition = true
        defer { isLookingUpNutrition = false }

        do {
            if let item = try await nutritionLookupService.lookupNutrition(
                for: name,
                weightGrams: grams
            ) {
                var newItem = item
                newItem.userConfirmed = true
                newItem.estimatedWeightG = grams
                foodItems.append(newItem)
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    var allWeightsConfirmed: Bool {
        !foodItems.isEmpty
    }

    var confidenceLevelText: String {
        let avg = detectedFoods.compactMap { $0.confidence }.reduce(0, +) / Double(detectedFoods.count)
        if avg >= 0.8 { return "High" }
        if avg >= 0.5 { return "Medium" }
        return "Low"
    }
}
