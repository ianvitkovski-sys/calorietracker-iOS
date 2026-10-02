import Foundation
import SwiftData

protocol FoodDetectionServiceProtocol {
    func detectFood(in image: UIImage, completion: @escaping (Result<[DetectedFood], DetectionError>) -> Void)
}

protocol WeightEstimationServiceProtocol {
    func estimateWeight(
        for food: DetectedFood,
        image: UIImage,
        imageSize: CGSize
    ) async -> WeightEstimate
}

protocol NutritionLookupServiceProtocol {
    func lookupNutrition(for foodName: String, weightGrams: Double) async throws -> FoodItemInMeal?
    func bootstrapDatabase() async
}

protocol NutritionCalculatorProtocol {
    func calculateDailyTargets(for user: User) -> (calories: Int, protein: Double, carbs: Double, fat: Double)
    func aggregateNutrition(for items: [FoodItemInMeal]) -> (calories: Double, protein: Double, carbs: Double, fat: Double, fiber: Double, sugar: Double, sodium: Double)
}

protocol ImageStorageServiceProtocol {
    func saveImage(_ image: UIImage) async throws -> String
    func loadImage(named filename: String) -> UIImage?
    func deleteImage(named filename: String) async throws
}

protocol HapticsServiceProtocol {
    func lightImpact()
    func mediumImpact()
    func heavyImpact()
    func success()
    func error()
    func photoCapture()
    func photoSaved()
}
