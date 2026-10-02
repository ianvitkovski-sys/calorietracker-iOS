import SwiftData
import Foundation
import SwiftUI

@Model
final class MealLog {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var timestamp: Date
    var mealType: MealType
    var imagePath: String?
    var notes: String?
    var items: [FoodItemInMeal]
    var totalCalories: Double
    var totalProteinG: Double
    var totalCarbsG: Double
    var totalFatG: Double
    var totalFiberG: Double
    var totalSugarG: Double
    var totalSodiumG: Double
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        timestamp: Date = Date(),
        mealType: MealType,
        imagePath: String? = nil,
        notes: String? = nil,
        items: [FoodItemInMeal] = [],
        totalCalories: Double = 0,
        totalProteinG: Double = 0,
        totalCarbsG: Double = 0,
        totalFatG: Double = 0,
        totalFiberG: Double = 0,
        totalSugarG: Double = 0,
        totalSodiumG: Double = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.timestamp = timestamp
        self.mealType = mealType
        self.imagePath = imagePath
        self.notes = notes
        self.items = items
        self.totalCalories = totalCalories
        self.totalProteinG = totalProteinG
        self.totalCarbsG = totalCarbsG
        self.totalFatG = totalFatG
        self.totalFiberG = totalFiberG
        self.totalSugarG = totalSugarG
        self.totalSodiumG = totalSodiumG
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var progressColor: Color {
        Color(UIColor.systemGreen)
    }

    func calculateTotals() {
        totalCalories = items.reduce(0) { $0 + $1.calories }
        totalProteinG = items.reduce(0) { $0 + $1.proteinG }
        totalCarbsG = items.reduce(0) { $0 + $1.carbsG }
        totalFatG = items.reduce(0) { $0 + $1.fatG }
        totalFiberG = items.reduce(0) { $0 + $1.fiberG }
        totalSugarG = items.reduce(0) { $0 + $1.sugarG }
        totalSodiumG = items.reduce(0) { $0 + $1.sodiumMg / 1000.0 }
    }
}
