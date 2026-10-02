import Foundation

struct AppConfiguration {
    static let isDebug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    static let apiBaseURL: String = "https://api.nal.usda.gov/fdc/v1/"
    static let usdaAPIKey: String = Bundle.main.object(forInfoDictionaryKey: "USDA_API_KEY") as? String ?? ""

    static let imageCompressionQuality: CGFloat = 0.85
    static let maxImageDimension: CGFloat = 1024

    static let weightEstimationConfidenceThreshold: Double = 0.5
    static let detectionConfidenceThreshold: Double = 0.5

    static let defaultMealPortionGrams: Double = 150.0
    static let minWeightGrams: Double = 10.0
    static let maxWeightGrams: Double = 1000.0
    static let weightStepGrams: Double = 5.0

    static let caloriesPerGramProtein: Double = 4.0
    static let caloriesPerGramCarbs: Double = 4.0
    static let caloriesPerGramFat: Double = 9.0
}
