import Foundation
import SwiftData
import UIKit

@MainActor
final class DataManager {
    static let shared = DataManager()
    private let container: ModelContainer

    private init() {
        container = PersistenceController.shared.container
    }

    var context: ModelContext { container.mainContext }

    func fetchMeals(for userId: UUID, in dateRange: ClosedRange<Date>? = nil) async throws -> [MealLog] {
        let descriptor: FetchDescriptor<MealLog>
        if let range = dateRange {
            descriptor = FetchDescriptor<MealLog>(
                predicate: #Predicate { $0.userId == userId && $0.timestamp >= range.lowerBound && $0.timestamp <= range.upperBound },
                sortBy: [SortDescriptor(\MealLog.timestamp)]
            )
        } else {
            descriptor = FetchDescriptor<MealLog>(
                predicate: #Predicate { $0.userId == userId },
                sortBy: [SortDescriptor(\MealLog.timestamp)]
            )
        }
        return try context.fetch(descriptor)
    }

    func fetchMeals(for date: Date, userId: UUID) async throws -> [MealLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return try await fetchMeals(for: userId, in: startOfDay...endOfDay)
    }

    func fetchDailySummary(for date: Date, userId: UUID) async throws -> DailySummary? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let descriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate { $0.userId == userId && $0.date == startOfDay },
            sortBy: [SortDescriptor(\DailySummary.date)]
        )
        let results = try context.fetch(descriptor)
        return results.first
    }

    func saveMealLog(_ mealLog: MealLog) async throws {
        context.insert(mealLog)
        try context.save()
    }

    func updateMealLog(_ mealLog: MealLog) async throws {
        try context.save()
    }

    func deleteMealLog(_ mealLog: MealLog) async throws {
        context.delete(mealLog)
        try context.save()
    }

    func saveFoodDatabaseEntry(_ entry: FoodDatabaseEntry) async throws {
        context.insert(entry)
        try context.save()
    }

    func fetchFoodEntry(by fdcId: String) async throws -> FoodDatabaseEntry? {
        let descriptor = FetchDescriptor<FoodDatabaseEntry>(
            predicate: #Predicate { $0.fdcId == fdcId }
        )
        return try context.fetch(descriptor).first
    }

    func searchFoodEntries(query: String) async throws -> [FoodDatabaseEntry] {
        let descriptor = FetchDescriptor<FoodDatabaseEntry>(
            predicate: #Predicate { $0.name.localizedStandardContains(query) },
            sortBy: [SortDescriptor(\FoodDatabaseEntry.name)]
        )
        return try context.fetch(descriptor).prefix(50).map { $0 }
    }

    func updateDailySummary(
        for date: Date,
        userId: UUID,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double,
        sugar: Double,
        sodium: Double
    ) async throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let descriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate { $0.userId == userId && $0.date == startOfDay }
        )

        if let summary = try context.fetch(descriptor).first {
            summary.totalCalories += calories
            summary.totalProteinG += protein
            summary.totalCarbsG += carbs
            summary.totalFatG += fat
            summary.totalFiberG += fiber
            summary.totalSugarG += sugar
            summary.totalSodiumG += sodium
            summary.updatedAt = Date()
        } else {
            let newSummary = DailySummary(
                userId: userId,
                date: startOfDay,
                totalCalories: calories,
                totalProteinG: protein,
                totalCarbsG: carbs,
                totalFatG: fat,
                totalFiberG: fiber,
                totalSugarG: sugar,
                totalSodiumG: sodium
            )
            context.insert(newSummary)
        }
        try context.save()
    }
}
