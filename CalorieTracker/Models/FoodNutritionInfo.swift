import Foundation

struct FoodNutritionInfo: Codable, Equatable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    let vitaminC: Double
    let vitaminA: Double
    let calcium: Double
    let iron: Double

    static func zero() -> FoodNutritionInfo {
        FoodNutritionInfo(
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            fiber: 0,
            sugar: 0,
            sodium: 0,
            vitaminC: 0,
            vitaminA: 0,
            calcium: 0,
            iron: 0
        )
    }

    static func +(lhs: FoodNutritionInfo, rhs: FoodNutritionInfo) -> FoodNutritionInfo {
        FoodNutritionInfo(
            calories: lhs.calories + rhs.calories,
            protein: lhs.protein + rhs.protein,
            carbs: lhs.carbs + rhs.carbs,
            fat: lhs.fat + rhs.fat,
            fiber: lhs.fiber + rhs.fiber,
            sugar: lhs.sugar + rhs.sugar,
            sodium: lhs.sodium + rhs.sodium,
            vitaminC: lhs.vitaminC + rhs.vitaminC,
            vitaminA: lhs.vitaminA + rhs.vitaminA,
            calcium: lhs.calcium + rhs.calcium,
            iron: lhs.iron + rhs.iron
        )
    }

    var macronutrientCalories: (protein: Double, carbs: Double, fat: Double) {
        (protein * 4, carbs * 4, fat * 9)
    }
}
