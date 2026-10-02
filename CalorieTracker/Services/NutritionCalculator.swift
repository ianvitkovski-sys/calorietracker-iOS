import Foundation

@MainActor
final class NutritionCalculator {
    func calculateDailyTargets(for user: User) -> (calories: Int, protein: Double, carbs: Double, fat: Double) {
        let bmr = user.bmr
        let activityLevel = user.activityLevel ?? .moderate
        let tdee = bmr * activityLevel.bmrMultiplier

        let dietaryGoal = user.dietaryGoal ?? .maintenance
        let adjustedCalories = tdee + dietaryGoal.calorieAdjustment
        let targetCalories = Int(adjustedCalories.rounded())

        let targets = dietaryGoal.defaultMacroRatio
        let proteinG = (adjustedCalories * targets.protein) / 4.0
        let carbsG = (adjustedCalories * targets.carbs) / 4.0
        let fatG = (adjustedCalories * targets.fat) / 9.0

        return (targetCalories, proteinG, carbsG, fatG)
    }

    func aggregateNutrition(for items: [FoodItemInMeal]) -> (
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double,
        sugar: Double,
        sodium: Double
    ) {
        let calories = items.reduce(0) { $0 + $1.calories }
        let protein = items.reduce(0) { $0 + $1.proteinG }
        let carbs = items.reduce(0) { $0 + $1.carbsG }
        let fat = items.reduce(0) { $0 + $1.fatG }
        let fiber = items.reduce(0) { $0 + $1.fiberG }
        let sugar = items.reduce(0) { $0 + $1.sugarG }
        let sodium = items.reduce(0) { $0 + $1.sodiumMg }

        return (calories, protein, carbs, fat, fiber, sugar, sodium)
    }

    func calculateWaterTarget(for user: User) -> Double {
        guard let weightKg = user.currentWeightKg else { return 2000 }
        return weightKg * 30.0
    }

    func calculateBMI(for user: User) -> Double? {
        guard let heightCm = user.currentWeightKg, let weightKg = user.currentWeightKg, heightCm > 0 else { return nil }
        return weightKg / pow(heightCm / 100.0, 2)
    }

    func dailyCalorieProgress(for consumed: Double, target: Int) -> Double {
        consumed / Double(target)
    }

    func macroProgress(
        consumedProtein: Double,
        consumedCarbs: Double,
        consumedFat: Double,
        targetProtein: Double,
        targetCarbs: Double,
        targetFat: Double
    ) -> (protein: Double, carbs: Double, fat: Double) {
        (
            protein: consumedProtein / (targetProtein > 0 ? targetProtein : 1),
            carbs: consumedCarbs / (targetCarbs > 0 ? targetCarbs : 1),
            fat: consumedFat / (targetFat > 0 ? targetFat : 1)
        )
    }
}
