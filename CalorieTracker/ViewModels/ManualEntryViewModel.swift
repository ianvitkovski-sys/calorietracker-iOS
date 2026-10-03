import Foundation
import SwiftData
import Combine

@MainActor
final class ManualEntryViewModel: ObservableObject {
    @Published var foodName: String = ""
    @Published var weightGrams: String = ""
    @Published var selectedMealType: MealType = .breakfast
    @Published var notes: String = ""
    @Published var searchResults: [FoodDatabaseEntry] = []
    @Published var isSearching = false
    @Published var isSaving = false
    @Published var selectedFood: FoodDatabaseEntry?
    @Published var showFoodPicker = false
    @Published var errorMessage: String?

    weak var container: AppContainer?

    init(container: AppContainer) {
        self.container = container
    }

    var weightDouble: Double? {
        Double(weightGrams)
    }

    var nutritionInfo: FoodNutritionInfo? {
        guard let food = selectedFood, let grams = weightDouble else { return nil }
        return food.nutrition(for: grams)
    }

    func searchFoods(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        Task {
            do {
                let results = try await DataManager.shared.searchFoodEntries(query: query)
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSearching = false
                }
            }
        }
    }

    func selectFood(_ food: FoodDatabaseEntry) {
        selectedFood = food
        foodName = food.name
        searchResults = []
    }

    func saveMeal() async -> Bool {
        guard let user = container?.currentUser else { return false }
        guard let food = selectedFood, let grams = weightDouble else { return false }

        isSaving = true
        defer { isSaving = false }

        let nutrition = food.nutrition(for: grams)
        let item = FoodItemInMeal(
            mealLogId: UUID(),
            foodDatabaseId: food.fdcId,
            foodName: food.name,
            estimatedWeightG: grams,
            calories: nutrition.calories,
            proteinG: nutrition.protein,
            carbsG: nutrition.carbs,
            fatG: nutrition.fat,
            fiberG: nutrition.fiber,
            sugarG: nutrition.sugar,
            sodiumMg: nutrition.sodium,
            vitaminCMg: nutrition.vitaminC,
            vitaminA: nutrition.vitaminA,
            calciumMg: nutrition.calcium,
            ironMg: nutrition.iron,
            userConfirmed: true
        )

        let mealLog = MealLog(
            userId: user.id,
            timestamp: Date(),
            mealType: selectedMealType,
            notes: notes.isEmpty ? nil : notes,
            items: [item],
            totalCalories: nutrition.calories,
            totalProteinG: nutrition.protein,
            totalCarbsG: nutrition.carbs,
            totalFatG: nutrition.fat,
            totalFiberG: nutrition.fiber,
            totalSugarG: nutrition.sugar,
            totalSodiumG: nutrition.sodium
        )

        do {
            try await DataManager.shared.saveMealLog(mealLog)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
