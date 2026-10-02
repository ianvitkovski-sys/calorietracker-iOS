import Foundation

struct MacroTargets: Codable, Equatable {
    var proteinPercent: Int
    var carbsPercent: Int
    var fatPercent: Int

    init(proteinPercent: Int = 20, carbsPercent: Int = 50, fatPercent: Int = 30) {
        self.proteinPercent = proteinPercent
        self.carbsPercent = carbsPercent
        self.fatPercent = fatPercent
    }

    func grams(for dailyCalories: Int) -> (protein: Double, carbs: Double, fat: Double) {
        let proteinCal = Double(dailyCalories) * (Double(proteinPercent) / 100.0)
        let carbsCal = Double(dailyCalories) * (Double(carbsPercent) / 100.0)
        let fatCal = Double(dailyCalories) * (Double(fatPercent) / 100.0)

        return (
            protein: proteinCal / 4.0,
            carbs: carbsCal / 4.0,
            fat: fatCal / 9.0
        )
    }
}
