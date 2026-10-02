import Foundation
import UIKit
import CoreML
import AVFoundation

final class WeightEstimationService {
    private let referenceObjectSizes: [String: CGSize] = [
        "coin_quarter": CGSize(width: 24.26, height: 24.26),
        "coin_dime": CGSize(width: 17.91, height: 17.91),
        "coin_penny": CGSize(width: 19.05, height: 19.05),
        "credit_card": CGSize(width: 85.60, height: 53.98)
    ]

    func estimateWeight(
        for food: DetectedFood,
        image: UIImage,
        imageSize: CGSize
    ) async -> WeightEstimate {
        var estimates: [(weight: Double, confidence: Double, method: WeightEstimationMethod)] = []

        if let depthBased = await estimateFromDepth(food: food, image: image) {
            estimates.append((depthBased.weight, depthBased.confidence, depthBased.method))
        }

        if let referenceBased = estimateFromReferenceObjects(food: food, image: image, imageSize: imageSize) {
            estimates.append((referenceBased.weight, referenceBased.confidence, referenceBased.method))
        }

        if let heuristicBased = estimateFromHeuristics(food: food) {
            estimates.append((heuristicBased.weight, heuristicBased.confidence, heuristicBased.method))
        }

        let fused = fuseEstimates(estimates)

        return WeightEstimate(
            foodName: food.className,
            estimatedGrams: fused.weight,
            confidence: fused.confidence,
            method: fused.method
        )
    }

    private func estimateFromDepth(food: DetectedFood, image: UIImage) -> (weight: Double, confidence: Double, method: WeightEstimationMethod)? {
        return nil
    }

    private func estimateFromReferenceObjects(food: DetectedFood, image: UIImage, imageSize: CGSize) -> (weight: Double, confidence: Double, method: WeightEstimationMethod)? {
        let heuristicWeight = getHeuristicBaseWeight(for: food.className)
        return (heuristicWeight, 0.35, .referenceObject)
    }

    private func estimateFromHeuristics(food: DetectedFood) -> (weight: Double, confidence: Double, method: WeightEstimationMethod)? {
        let weight = getHeuristicBaseWeight(for: food.className)
        return (weight, 0.20, .portionHeuristic)
    }

    private func fuseEstimates(_ estimates: [(weight: Double, confidence: Double, method: WeightEstimationMethod)]) -> (weight: Double, confidence: Double, method: WeightEstimationMethod) {
        guard !estimates.isEmpty else {
            return (100.0, 0.5, .fused)
        }

        var weightedSum: Double = 0
        var totalConfidence: Double = 0

        for estimate in estimates {
            weightedSum += estimate.weight * estimate.confidence
            totalConfidence += estimate.confidence
        }

        let avgWeight = totalConfidence > 0 ? weightedSum / totalConfidence : 100.0
        let avgConfidence = totalConfidence / Double(estimates.count)

        return (avgWeight, min(avgConfidence, 0.95), .fused)
    }

    private func getHeuristicBaseWeight(for foodClassName: String) -> Double {
        return FoodPortionHeuristics.defaultWeight(for: foodClassName)
    }
}
