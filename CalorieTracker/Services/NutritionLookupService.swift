import Foundation
import SwiftData

@MainActor
final class NutritionLookupService {
    private let modelContext: ModelContext
    private var nutrientCache: [String: FoodDatabaseEntry] = [:]

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func lookupNutrition(for foodName: String, weightGrams: Double) async throws -> FoodItemInMeal? {
        let fdcId = FoodClassMapper.mapToFoodDatabaseId(foodName)

        if let cached = nutrientCache[fdcId ?? foodName.lowercased()] {
            return createFoodItem(from: cached, weightGrams: weightGrams, foodName: foodName, fdcId: fdcId)
        }

        if let entry = try fetchLocalEntry(fdcId: fdcId ?? foodName, name: foodName) {
            nutrientCache[fdcId ?? foodName.lowercased()] = entry
            return createFoodItem(from: entry, weightGrams: weightGrams, foodName: foodName, fdcId: fdcId)
        }

        return try await fetchFromAPI(foodName: foodName, weightGrams: weightGrams)
    }

    private func fetchLocalEntry(fdcId: String, name: String) throws -> FoodDatabaseEntry? {
        if !fdcId.isEmpty {
            let descriptor = FetchDescriptor<FoodDatabaseEntry>(
                predicate: #Predicate { $0.fdcId == fdcId }
            )
            if let results = try modelContext.fetch(descriptor).first {
                return results
            }
        }

        let descriptor = FetchDescriptor<FoodDatabaseEntry>(
            predicate: #Predicate { $0.name.localizedStandardContains(name) }
        )
        return try modelContext.fetch(descriptor).first
    }

    private func fetchFromAPI(foodName: String, weightGrams: Double) async throws -> FoodItemInMeal? {
        let fdcId = try await USDAService.shared.searchFood(query: foodName)
        guard let id = fdcId else { return nil }

        let response = try await USDAService.shared.getFoodDetails(fdcId: id)

        let entry = FoodDatabaseEntry(
            fdcId: String(id),
            name: response.description,
            category: response.foodCategory,
            caloriesPer100g: response.nutrients.first(where: { $0.name == "Energy" })?.amount ?? 0,
            proteinPer100g: response.nutrients.first(where: { $0.name == "Protein" })?.amount ?? 0,
            carbsPer100g: response.nutrients.first(where: { $0.name == "Carbohydrates" })?.amount ?? 0,
            fatPer100g: response.nutrients.first(where: { $0.name == "Total Fat" })?.amount ?? 0,
            fiberPer100g: response.nutrients.first(where: { $0.name == "Fiber" })?.amount ?? 0,
            sugarPer100g: response.nutrients.first(where: { $0.name == "Sugars" })?.amount ?? 0,
            sodiumPer100g: response.nutrients.first(where: { $0.name == "Sodium" })?.amount ?? 0,
            vitaminCPer100g: response.nutrients.first(where: { $0.name == "Vitamin C" })?.amount ?? 0,
            vitaminAPer100g: response.nutrients.first(where: { $0.name == "Vitamin A" })?.amount ?? 0,
            calciumPer100g: response.nutrients.first(where: { $0.name == "Calcium" })?.amount ?? 0,
            ironPer100g: response.nutrients.first(where: { $0.name == "Iron" })?.amount ?? 0,
            isOfflineCapable: false
        )

        modelContext.insert(entry)
        try modelContext.save()

        nutrientCache[String(id)] = entry
        return createFoodItem(from: entry, weightGrams: weightGrams, foodName: foodName, fdcId: fdcId)
    }

    private func createFoodItem(
        from entry: FoodDatabaseEntry,
        weightGrams: Double,
        foodName: String,
        fdcId: String?
    ) -> FoodItemInMeal {
        let ratio = weightGrams / 100.0

        return FoodItemInMeal(
            mealLogId: UUID(),
            foodDatabaseId: fdcId ?? entry.fdcId,
            foodName: entry.name,
            estimatedWeightG: weightGrams,
            calories: entry.caloriesPer100g * ratio,
            proteinG: entry.proteinPer100g * ratio,
            carbsG: entry.carbsPer100g * ratio,
            fatG: entry.fatPer100g * ratio,
            fiberG: entry.fiberPer100g * ratio,
            sugarG: entry.sugarPer100g * ratio,
            sodiumMg: entry.sodiumPer100g * ratio,
            vitaminCMg: entry.vitaminCPer100g * ratio,
            vitaminA: entry.vitaminAPer100g * ratio,
            calciumMg: entry.calciumPer100g * ratio,
            ironMg: entry.ironPer100g * ratio,
            detectionConfidence: nil,
            userConfirmed: false
        )
    }

    func bootstrapDatabase() async {
        let count = try? await fetchEntryCount()
        if count == 0 {
            await seedDatabase()
        }
    }

    private func fetchEntryCount() async throws -> Int {
        let descriptor = FetchDescriptor<FoodDatabaseEntry>()
        return try modelContext.fetch(descriptor).count
    }

    private func seedDatabase() async {
        let seedData = FoodDatabaseSeeder.seedData

        for entryData in seedData {
            let entry = FoodDatabaseEntry(
                fdcId: entryData.fdcId,
                name: entryData.name,
                category: entryData.category,
                caloriesPer100g: entryData.caloriesPer100g,
                proteinPer100g: entryData.proteinPer100g,
                carbsPer100g: entryData.carbsPer100g,
                fatPer100g: entryData.fatPer100g,
                fiberPer100g: entryData.fiberPer100g,
                sugarPer100g: entryData.sugarPer100g,
                sodiumPer100g: entryData.sodiumPer100g,
                vitaminCPer100g: entryData.vitaminCPer100g,
                vitaminAPer100g: entryData.vitaminAPer100g,
                calciumPer100g: entryData.calciumPer100g,
                ironPer100g: entryData.ironPer100g,
                isOfflineCapable: true
            )
            modelContext.insert(entry)
        }

        try? modelContext.save()
    }
}
