import SwiftData
import Foundation

@Model
final class DailySummary {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var date: Date
    var totalCalories: Double
    var totalProteinG: Double
    var totalCarbsG: Double
    var totalFatG: Double
    var totalFiberG: Double
    var totalSugarG: Double
    var totalSodiumG: Double
    var waterIntakeML: Double?
    var stepCount: Int?
    var morningWeightKg: Double?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        date: Date,
        totalCalories: Double = 0,
        totalProteinG: Double = 0,
        totalCarbsG: Double = 0,
        totalFatG: Double = 0,
        totalFiberG: Double = 0,
        totalSugarG: Double = 0,
        totalSodiumG: Double = 0,
        waterIntakeML: Double? = nil,
        stepCount: Int? = nil,
        morningWeightKg: Double? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.totalCalories = totalCalories
        self.totalProteinG = totalProteinG
        self.totalCarbsG = totalCarbsG
        self.totalFatG = totalFatG
        self.totalFiberG = totalFiberG
        self.totalSugarG = totalSugarG
        self.totalSodiumG = totalSodiumG
        self.waterIntakeML = waterIntakeML
        self.stepCount = stepCount
        self.morningWeightKg = morningWeightKg
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
