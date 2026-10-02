import Foundation

@MainActor
final class ProfileSetupViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var gender: Gender?
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var goalWeight: String = ""
    @Published var dateOfBirth: Date?
    @Published var activityLevel: ActivityLevel = .moderate
    @Published var dietaryGoal: DietaryGoal = .maintenance
    @Published var isSaving = false
    @Published var errorMessage: String?

    weak var container: AppContainer?

    init(container: AppContainer) {
        self.container = container
    }

    var isFormValid: Bool {
        !name.isEmpty &&
        !height.isEmpty &&
        !weight.isEmpty &&
        gender != nil &&
        dateOfBirth != nil
    }

    var recommendedCalories: Int {
        guard let heightDouble = Double(height),
              let weightDouble = Double(weight),
              let dob = dateOfBirth,
              let gender = gender else { return 2000 }

        let age = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 30
        let bmr: Double

        switch gender {
        case .male:
            bmr = 10 * weightDouble + 6.25 * heightDouble - 5 * Double(age) + 5
        case .female:
            bmr = 10 * weightDouble + 6.25 * heightDouble - 5 * Double(age) - 161
        case .other:
            bmr = 10 * weightDouble + 6.25 * heightDouble - 5 * Double(age) - 78
        }

        return Int((bmr * activityLevel.bmrMultiplier + dietaryGoal.calorieAdjustment).rounded())
    }

    func saveProfile() async -> Bool {
        guard isFormValid else { return false }

        isSaving = true
        defer { isSaving = false }

        let targets = MacroTargets()
        let user = User(
            name: name,
            dateOfBirth: dateOfBirth,
            gender: gender,
            heightCm: Double(height),
            startingWeightKg: Double(weight),
            currentWeightKg: Double(weight),
            goalWeightKg: goalWeight.isEmpty ? nil : Double(goalWeight),
            activityLevel: activityLevel,
            dietaryGoal: dietaryGoal,
            dailyCalorieTarget: recommendedCalories,
            macroTargets: targets,
            isProfileComplete: true
        )

        user.updatedAt = Date()
        await MainActor.run {
            container?.updateCurrentUser(user)
        }

        return true
    }
}
