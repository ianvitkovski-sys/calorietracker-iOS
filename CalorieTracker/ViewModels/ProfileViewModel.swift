import Foundation
import SwiftData
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var dailyCalories: Int = 2000
    @Published var dailyProtein: Double = 100
    @Published var dailyCarbs: Double = 250
    @Published var dailyFat: Double = 67
    @Published var dailyWater: Double = 2000
    @Published var isLoading = false
    @Published var showSettings = false

    weak var container: AppContainer?
    private var cancellables = Set<AnyCancellable>()

    init(container: AppContainer) {
        self.container = container
        self.user = container.currentUser
        calculateDailyTargets()
        setupObservers()
    }

    private func setupObservers() {
        container?.objectWillChange
            .sink { [weak self] in
                self?.user = self?.container?.currentUser
                self?.calculateDailyTargets()
            }
            .store(in: &cancellables)
    }

    private func calculateDailyTargets() {
        guard let user else { return }
        let targets = container?.nutritionCalculator.calculateDailyTargets(for: user) ?? (2000, 100, 250, 67)
        dailyCalories = targets.calories
        dailyProtein = targets.protein
        dailyCarbs = targets.carbs
        dailyFat = targets.fat
        dailyWater = container?.nutritionCalculator.calculateWaterTarget(for: user) ?? 2000
    }

    func recalculate() {
        calculateDailyTargets()
    }

    func updateProfile(name: String, height: String, weight: String, goal: DietaryGoal, activity: ActivityLevel) {
        guard let user else { return }

        user.name = name.isEmpty ? user.name : name
        user.heightCm = Double(height) ?? user.heightCm
        user.currentWeightKg = Double(weight) ?? user.currentWeightKg
        user.dietaryGoal = goal
        user.activityLevel = activity

        if user.startingWeightKg == nil {
            user.startingWeightKg = user.currentWeightKg
        }

        container?.updateCurrentUser(user)
    }

    func updateWaterIntake(_ amount: Double) {
        dailyWater = amount
    }

    var bmi: Double? {
        guard let user = user, let heightCm = user.heightCm, let weightKg = user.currentWeightKg, heightCm > 0 else { return nil }
        return weightKg / pow(heightCm / 100.0, 2)
    }

    var bmiCategory: String {
        guard let bmi = bmi else { return "N/A" }
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }

    var progressToGoal: Double {
        guard let user = user, let start = user.startingWeightKg, let goal = user.goalWeightKg else { return 0 }
        let total = abs(start - goal)
        let current = abs((user.currentWeightKg ?? start) - goal)
        return total > 0 ? max(0, min(1, (total - current) / total)) : 0
    }
}
