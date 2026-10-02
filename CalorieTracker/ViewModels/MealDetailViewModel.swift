import Foundation
import SwiftData

@MainActor
final class MealDetailViewModel: ObservableObject {
    @Published var meal: MealLog
    @Published var errorMessage: String?
    @Published var showError = false

    weak var container: AppContainer?

    init(meal: MealLog, container: AppContainer) {
        self.meal = meal
        self.container = container
    }

    func deleteMeal() {
        Task {
            do {
                try await DataManager.shared.deleteMealLog(meal)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    func recalculateTotals() {
        meal.calculateTotals()
    }
}
