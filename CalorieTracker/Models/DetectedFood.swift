import Foundation
import CoreGraphics

struct DetectedFood: Identifiable, Equatable {
    let id = UUID()
    let className: String
    let confidence: Double
    let boundingBox: CGRect
    let foodDatabaseId: String?

    var isHighConfidence: Bool { confidence >= 0.8 }
    var isMediumConfidence: Bool { confidence >= 0.5 && confidence < 0.8 }
    var isLowConfidence: Bool { confidence < 0.5 }
}
