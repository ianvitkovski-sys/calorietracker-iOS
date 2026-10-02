import SwiftData
import Foundation

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var dateOfBirth: Date?
    var gender: Gender?
    var heightCm: Double?
    var startingWeightKg: Double?
    var currentWeightKg: Double?
    var goalWeightKg: Double?
    var activityLevel: ActivityLevel?
    var dietaryGoal: DietaryGoal?
    var dailyCalorieTarget: Int?
    var macroTargets: MacroTargets?
    var isProfileComplete: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        dateOfBirth: Date? = nil,
        gender: Gender? = nil,
        heightCm: Double? = nil,
        startingWeightKg: Double? = nil,
        currentWeightKg: Double? = nil,
        goalWeightKg: Double? = nil,
        activityLevel: ActivityLevel? = nil,
        dietaryGoal: DietaryGoal? = nil,
        dailyCalorieTarget: Int? = nil,
        macroTargets: MacroTargets? = nil,
        isProfileComplete: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.heightCm = heightCm
        self.startingWeightKg = startingWeightKg
        self.currentWeightKg = currentWeightKg
        self.goalWeightKg = goalWeightKg
        self.activityLevel = activityLevel
        self.dietaryGoal = dietaryGoal
        self.dailyCalorieTarget = dailyCalorieTarget
        self.macroTargets = macroTargets
        self.isProfileComplete = isProfileComplete
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var bmr: Double {
        guard let gender, let heightCm, let currentWeightKg, let dateOfBirth else { return 0 }
        let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        switch gender {
        case .male:
            return 10 * currentWeightKg + 6.25 * heightCm - 5 * Double(age) + 5
        case .female:
            return 10 * currentWeightKg + 6.25 * heightCm - 5 * Double(age) - 161
        case .other:
            return 10 * currentWeightKg + 6.25 * heightCm - 5 * Double(age) - 78
        }
    }

    var calculatedDailyCalorieTarget: Int {
        if let dailyCalorieTarget { return dailyCalorieTarget }
        guard let activityLevel, bmr > 0 else { return 2000 }
        let tdee = bmr * activityLevel.bmrMultiplier
        let goalAdjustment = dietaryGoal?.calorieAdjustment ?? 0
        return Int(tdee + goalAdjustment)
    }

    var age: Int? {
        guard let dateOfBirth else { return nil }
        return Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year
    }
}
