import Foundation

struct AppConstants {
    static let appName = "CalorieTracker"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    static let dailyWaterReminderHours: Set<Int> = [9, 11, 13, 15, 17, 19]

    static let defaultMealTimes: [MealType: String] = [
        .breakfast: "08:00",
        .lunch: "12:00",
        .dinner: "18:00",
        .snack: "15:00"
    ]

    static let confidenceThresholds: (high: Double, medium: Double) = (0.8, 0.5)

    static let maxDetectedFoods = 5
    static let maxSearchResults = 50

    static let minWeightGrams: Double = 10.0
    static let maxWeightGrams: Double = 1000.0
    static let weightStepGrams: Double = 5.0
}
