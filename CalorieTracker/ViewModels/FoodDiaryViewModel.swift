import Foundation
import SwiftData
import Combine

@MainActor
final class FoodDiaryViewModel: ObservableObject {
    @Published var meals: [MealLog] = []
    @Published var selectedDate: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?

    weak var container: AppContainer?

    init(container: AppContainer) {
        self.container = container
    }

    var mealsForSelectedDate: [MealLog] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: selectedDate)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        return meals.filter { $0.timestamp >= start && $0.timestamp < end }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var mealsGroupedByDay: [Date: [MealLog]] {
        Dictionary(grouping: meals, by: { Calendar.current.startOfDay(for: $0.timestamp) })
    }

    var todaysTotalCalories: Double {
        let calendar = Calendar.current
        let todaysMeals = meals.filter { calendar.isDate($0.timestamp, inSameDayAs: Date()) }
        return todaysMeals.compactMap { $0.items }.flatMap { $0 }.reduce(0) { $0 + $1.calories }
    }

    var todaysTotalProtein: Double {
        let calendar = Calendar.current
        let todaysMeals = meals.filter { calendar.isDate($0.timestamp, inSameDayAs: Date()) }
        return todaysMeals.compactMap { $0.items }.flatMap { $0 }.reduce(0) { $0 + $1.proteinG }
    }

    var todaysTotalCarbs: Double {
        let calendar = Calendar.current
        let todaysMeals = meals.filter { calendar.isDate($0.timestamp, inSameDayAs: Date()) }
        return todaysMeals.compactMap { $0.items }.flatMap { $0 }.reduce(0) { $0 + $1.carbsG }
    }

    var todaysTotalFat: Double {
        let calendar = Calendar.current
        let todaysMeals = meals.filter { calendar.isDate($0.timestamp, inSameDayAs: Date()) }
        return todaysMeals.compactMap { $0.items }.flatMap { $0 }.reduce(0) { $0 + $1.fatG }
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        guard let user = container?.currentUser else { return }

        do {
            let allMeals = try await DataManager.shared.fetchMeals(for: user.id)
            meals = allMeals
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteMeal(_ meal: MealLog) {
        Task {
            do {
                try await DataManager.shared.deleteMealLog(meal)
                await loadData()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func navigateToMealDetail(_ meal: MealLog) {
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }

    func goToToday() {
        selectedDate = Date()
    }

    func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }

    func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
}
