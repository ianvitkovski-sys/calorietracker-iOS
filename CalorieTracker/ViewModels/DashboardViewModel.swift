import Foundation
import SwiftData
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var todaysMeals: [MealLog] = []
    @Published var dailyCalories: Double = 0
    @Published var dailyProtein: Double = 0
    @Published var dailyCarbs: Double = 0
    @Published var dailyFat: Double = 0
    @Published var dailyWater: Double = 500
    @Published var selectedDate: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?

    weak var container: AppContainer?
    private var cancellables = Set<AnyCancellable>()

    init(container: AppContainer) {
        self.container = container
        setupObservers()
    }

    private func setupObservers() {
        container?.objectWillChange
            .sink { [weak self] in
                Task { await self?.loadData() }
            }
            .store(in: &cancellables)
    }

    var calorieTarget: Int {
        guard let user = container?.currentUser else { return 2000 }
        return user.calculatedDailyCalorieTarget
    }

    var calorieProgress: Double {
        dailyCalories / Double(calorieTarget)
    }

    var macroTargets: (protein: Double, carbs: Double, fat: Double) {
        let calculator = container?.nutritionCalculator
        let user = container?.currentUser ?? User(name: "Guest")
        let targets = calculator?.calculateDailyTargets(for: user) ?? (2000, 100, 200, 67)
        return (targets.protein, targets.carbs, targets.fat)
    }

    var proteinProgress: Double {
        dailyProtein / (macroTargets.protein > 0 ? macroTargets.protein : 1)
    }

    var carbsProgress: Double {
        dailyCarbs / (macroTargets.carbs > 0 ? macroTargets.carbs : 1)
    }

    var fatProgress: Double {
        dailyFat / (macroTargets.fat > 0 ? macroTargets.fat : 1)
    }

    var waterTarget: Double {
        guard let user = container?.currentUser else { return 2000 }
        return container?.nutritionCalculator.calculateWaterTarget(for: user) ?? 2000
    }

    var waterProgress: Double {
        dailyWater / waterTarget
    }

    var hasRemainingCalories: Bool {
        calorieProgress < 1.0
    }

    var remainingCalories: Int {
        max(0, calorieTarget - Int(dailyCalories))
    }

    var mealsByDay: [Date: [MealLog]] {
        Dictionary(grouping: todaysMeals, by: { Calendar.current.startOfDay(for: $0.timestamp) })
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        guard let user = container?.currentUser else { return }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: selectedDate)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        do {
            let meals = try await DataManager.shared.fetchMeals(for: user.id, in: start...end)
            todaysMeals = meals.sorted { $0.timestamp > $1.timestamp }

            let totals = container?.nutritionCalculator.aggregateNutrition(
                for: meals.compactMap { $0.items }.flatMap { $0 }
            ) ?? (0, 0, 0, 0, 0, 0, 0)

            dailyCalories = totals.calories
            dailyProtein = totals.protein
            dailyCarbs = totals.carbs
            dailyFat = totals.fat
            dailyWater = meals.compactMap { $0.items }.flatMap { $0 }
                .filter { $0.foodName.lowercased().contains("water") }
                .reduce(0) { $0 + $1.calories }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await loadData()
    }
}
