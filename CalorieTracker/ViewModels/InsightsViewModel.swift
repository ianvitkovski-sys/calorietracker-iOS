import Foundation
import SwiftData
import Charts
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var weeklyData: [DailySummary] = []
    @Published var monthlyData: [DailySummary] = []
    @Published var selectedPeriod: InsightsPeriod = .weekly
    @Published var isLoading = false
    @Published var errorMessage: String?

    weak var container: AppContainer?
    private let calendar = Calendar.current

    enum InsightsPeriod: String, CaseIterable, Identifiable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"

        var id: String { rawValue }

        var days: Int {
            switch self {
            case .weekly: return 7
            case .monthly: return 30
            case .yearly: return 365
            }
        }
    }

    init(container: AppContainer) {
        self.container = container
        Task { await loadData() }
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        guard let user = container?.currentUser else { return }

        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedPeriod.days, to: endDate)!

        do {
            let meals = try await DataManager.shared.fetchMeals(for: user.id, in: startDate...endDate)

            let summariesByDate = Dictionary(grouping: meals) { calendar.startOfDay(for: $0.timestamp) }

            let summaries: [DailySummary] = Array((0..<selectedPeriod.days).compactMap { offset in
                let date = calendar.date(byAdding: .day, value: -offset, to: endDate)!
                let startOfDate = calendar.startOfDay(for: date)
                let dayMeals = summariesByDate[startOfDate] ?? []

                let calculator = container?.nutritionCalculator
                let totals = calculator?.aggregateNutrition(for: dayMeals.compactMap { $0.items }.flatMap { $0 }) ?? (0, 0, 0, 0, 0, 0, 0)

                return DailySummary(
                    userId: user.id,
                    date: startOfDate,
                    totalCalories: totals.calories,
                    totalProteinG: totals.protein,
                    totalCarbsG: totals.carbs,
                    totalFatG: totals.fat,
                    totalFiberG: totals.fiber,
                    totalSugarG: totals.sugar,
                    totalSodiumG: totals.sodium
                )
            }.reversed())

            weeklyData = summaries
            monthlyData = summaries
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await loadData()
    }

    var averageDailyCalories: Double {
        weeklyData.map(\.totalCalories).reduce(0, +) / Double(max(1, weeklyData.count))
    }

    var averageDailyProtein: Double {
        weeklyData.map(\.totalProteinG).reduce(0, +) / Double(max(1, weeklyData.count))
    }

    var averageDailyCarbs: Double {
        weeklyData.map(\.totalCarbsG).reduce(0, +) / Double(max(1, weeklyData.count))
    }

    var averageDailyFat: Double {
        weeklyData.map(\.totalFatG).reduce(0, +) / Double(max(1, weeklyData.count))
    }

    var totalCaloriesInPeriod: Double {
        weeklyData.map(\.totalCalories).reduce(0, +)
    }

    var calorieTrendDirection: TrendDirection {
        guard weeklyData.count >= 2 else { return .stable }
        let first = weeklyData.first?.totalCalories ?? 0
        let last = weeklyData.last?.totalCalories ?? 0
        if last > first * 1.05 { return .increasing }
        if last < first * 0.95 { return .decreasing }
        return .stable
    }

    enum TrendDirection {
        case increasing, decreasing, stable
    }
}
