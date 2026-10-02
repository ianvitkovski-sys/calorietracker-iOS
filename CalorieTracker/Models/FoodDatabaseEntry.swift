import SwiftData
import Foundation

@Model
final class FoodDatabaseEntry {
    @Attribute(.unique) var fdcId: String
    var name: String
    var category: String?
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var fiberPer100g: Double
    var sugarPer100g: Double
    var sodiumPer100g: Double
    var vitaminCPer100g: Double
    var vitaminAPer100g: Double
    var calciumPer100g: Double
    var ironPer100g: Double
    var isOfflineCapable: Bool

    init(
        fdcId: String,
        name: String,
        category: String? = nil,
        caloriesPer100g: Double,
        proteinPer100g: Double,
        carbsPer100g: Double,
        fatPer100g: Double,
        fiberPer100g: Double,
        sugarPer100g: Double,
        sodiumPer100g: Double,
        vitaminCPer100g: Double = 0,
        vitaminAPer100g: Double = 0,
        calciumPer100g: Double = 0,
        ironPer100g: Double = 0,
        isOfflineCapable: Bool = true
    ) {
        self.fdcId = fdcId
        self.name = name
        self.category = category
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
        self.fiberPer100g = fiberPer100g
        self.sugarPer100g = sugarPer100g
        self.sodiumPer100g = sodiumPer100g
        self.vitaminCPer100g = vitaminCPer100g
        self.vitaminAPer100g = vitaminAPer100g
        self.calciumPer100g = calciumPer100g
        self.ironPer100g = ironPer100g
        self.isOfflineCapable = isOfflineCapable
    }

    func nutrition(for gramAmount: Double) -> FoodNutritionInfo {
        let ratio = gramAmount / 100.0
        return FoodNutritionInfo(
            calories: caloriesPer100g * ratio,
            protein: proteinPer100g * ratio,
            carbs: carbsPer100g * ratio,
            fat: fatPer100g * ratio,
            fiber: fiberPer100g * ratio,
            sugar: sugarPer100g * ratio,
            sodium: sodiumPer100g * ratio,
            vitaminC: vitaminCPer100g * ratio,
            vitaminA: vitaminAPer100g * ratio,
            calcium: calciumPer100g * ratio,
            iron: ironPer100g * ratio
        )
    }
}
