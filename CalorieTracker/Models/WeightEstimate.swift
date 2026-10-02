import Foundation

struct WeightEstimate {
    let foodName: String
    let estimatedGrams: Double
    let confidence: Double
    let method: WeightEstimationMethod
    let userAdjusted: Bool

    init(
        foodName: String,
        estimatedGrams: Double,
        confidence: Double,
        method: WeightEstimationMethod,
        userAdjusted: Bool = false
    ) {
        self.foodName = foodName
        self.estimatedGrams = estimatedGrams
        self.confidence = confidence
        self.method = method
        self.userAdjusted = userAdjusted
    }
}

enum WeightEstimationMethod: String, Codable {
    case referenceObject = "Reference Object"
    case depthEstimation = "Depth Estimation (LiDAR)"
    case portionHeuristic = "Portion Heuristic"
    case userDefined = "User Defined"
    case fused = "Confidence-Weighted Fusion"
}
