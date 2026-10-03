import Foundation
import SwiftData
import SwiftUI

@MainActor
final class PreviewData {
    static var previewContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            MealLog.self,
            FoodItemInMeal.self,
            FoodDatabaseEntry.self,
            DailySummary.self
        ])

        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: config)
            populatePreviewData(into: container)
            return container
        } catch {
            fatalError("Preview container error: \(error)")
        }
    }()

    private static func populatePreviewData(into container: ModelContainer) {
        let context = container.mainContext

        let user = User(
            name: "Alex Johnson",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -1, to: Date()),
            gender: .male,
            heightCm: 180,
            startingWeightKg: 85,
            currentWeightKg: 80,
            goalWeightKg: 75,
            activityLevel: .moderate,
            dietaryGoal: .weightLoss,
            dailyCalorieTarget: 2200,
            macroTargets: MacroTargets(proteinPercent: 30, carbsPercent: 40, fatPercent: 30),
            isProfileComplete: true
        )
        context.insert(user)

        let foods = createSampleFoods()
        foods.forEach { context.insert($0) }

        let meals = createSampleMeals(userId: user.id)
        meals.forEach { context.insert($0) }

        try? context.save()
    }

    private static func createSampleFoods() -> [FoodDatabaseEntry] {
        [
            FoodDatabaseEntry(fdcId: "09003", name: "Apple", category: "Fruits",
                             caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14,
                             fatPer100g: 0.2, fiberPer100g: 2.4, sugarPer100g: 10,
                             sodiumPer100g: 1, vitaminCPer100g: 4.6, vitaminAPer100g: 54,
                             calciumPer100g: 6, ironPer100g: 0.1),
            FoodDatabaseEntry(fdcId: "06008", name: "Hamburger", category: "Meat",
                             caloriesPer100g: 250, proteinPer100g: 20, carbsPer100g: 17,
                             fatPer100g: 10, fiberPer100g: 2.4, sugarPer100g: 3.5,
                             sodiumPer100g: 380, vitaminCPer100g: 0, vitaminAPer100g: 18,
                             calciumPer100g: 120, ironPer100g: 2.1),
            FoodDatabaseEntry(fdcId: "07007", name: "Pizza", category: "Fast Food",
                             caloriesPer100g: 266, proteinPer100g: 11, carbsPer100g: 34,
                             fatPer100g: 10, fiberPer100g: 2.8, sugarPer100g: 3.2,
                             sodiumPer100g: 590, vitaminCPer100g: 3.4, vitaminAPer100g: 120,
                             calciumPer100g: 200, ironPer100g: 1.8)
        ]
    }

    private static func createSampleMeals(userId: UUID) -> [MealLog] {
        let item1 = FoodItemInMeal(
            mealLogId: UUID(),
            foodDatabaseId: "06008",
            foodName: "Hamburger",
            estimatedWeightG: 150,
            calories: 375,
            proteinG: 30,
            carbsG: 25.5,
            fatG: 15,
            fiberG: 3.6,
            sugarG: 5.25,
            sodiumMg: 570,
            userConfirmed: true
        )

        let meal1 = MealLog(
            userId: userId,
            timestamp: Date(),
            mealType: .lunch,
            items: [item1],
            totalCalories: 375,
            totalProteinG: 30,
            totalCarbsG: 25.5,
            totalFatG: 15,
            totalFiberG: 3.6,
            totalSugarG: 5.25,
            totalSodiumG: 0.57
        )

        let item2 = FoodItemInMeal(
            mealLogId: UUID(),
            foodDatabaseId: "09003",
            foodName: "Apple",
            estimatedWeightG: 182,
            calories: 95,
            proteinG: 0.5,
            carbsG: 25.5,
            fatG: 0.4,
            fiberG: 4.4,
            sugarG: 18.2,
            sodiumMg: 2,
            userConfirmed: true
        )

        let meal2 = MealLog(
            userId: userId,
            timestamp: Date().addingTimeInterval(-3600),
            mealType: .snack,
            items: [item2],
            totalCalories: 95,
            totalProteinG: 0.5,
            totalCarbsG: 25.5,
            totalFatG: 0.4,
            totalFiberG: 4.4,
            totalSugarG: 18.2,
            totalSodiumG: 0.002
        )

        return [meal1, meal2]
    }

    static var sampleDetectedFoods: [DetectedFood] {
        [
            DetectedFood(className: "hamburger", confidence: 0.92, boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.5, height: 0.4), foodDatabaseId: "06008"),
            DetectedFood(className: "french_fries", confidence: 0.87, boundingBox: CGRect(x: 0.6, y: 0.3, width: 0.3, height: 0.4), foodDatabaseId: "06030")
        ]
    }

    static var sampleWeightEstimate: WeightEstimate {
        WeightEstimate(foodName: "Hamburger", estimatedGrams: 150, confidence: 0.85, method: .fused)
    }
}
