import SwiftUI
import SwiftData
import Foundation

@MainActor
final class AppContainer: ObservableObject {
    static let shared = AppContainer()

    let modelContainer: ModelContainer
    let mainModelContext: ModelContext

    @Published var currentUser: User?

    var foodDetectionService: FoodDetectionService
    var weightEstimationService: WeightEstimationService
    var nutritionLookupService: NutritionLookupService
    var cameraService: CameraService
    var imagePreprocessingService: ImagePreprocessingService
    var nutritionCalculator: NutritionCalculator
    var apiService: APIService
    var hapticsService: HapticsService
    var imageStorageService: ImageStorageService

    private init() {
        let schema = Schema([
            User.self,
            MealLog.self,
            FoodItemInMeal.self,
            FoodDatabaseEntry.self,
            DailySummary.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            localizedError: nil
        )

        do {
            modelContainer = try ModelContainer(for: modelConfiguration)
            mainModelContext = modelContainer.mainContext
        } catch {
            print("CoreData: Failed to create model container: \(error)")
            modelContainer = Self.createFallbackContainer()
            mainModelContext = modelContainer.mainContext
        }

        foodDetectionService = FoodDetectionService()
        weightEstimationService = WeightEstimationService()
        nutritionLookupService = NutritionLookupService(modelContext: mainModelContext)
        cameraService = CameraService()
        imagePreprocessingService = ImagePreprocessingService()
        nutritionCalculator = NutritionCalculator()
        apiService = APIService()
        hapticsService = HapticsService()
        imageStorageService = ImageStorageService()

        Task {
            await loadCurrentUser()
            await nutritionLookupService.bootstrapDatabase()
        }
    }

    private static func createFallbackContainer() -> ModelContainer {
        do {
            return try ModelContainer.forSnapshots([])
        } catch {
            return try! ModelContainer(for: [])
        }
    }

    private func loadCurrentUser() async {
        let fetch = FetchDescriptor<User>()
        if let user = try? mainModelContext.fetch(fetch).first {
            currentUser = user
        } else {
            let newUser = User(name: "Guest")
            mainModelContext.insert(newUser)
            try? mainModelContext.save()
            currentUser = newUser
        }
    }

    func updateCurrentUser(_ user: User) {
        currentUser = user
        try? mainModelContext.save()
    }

    func deleteAllData() {
        try? mainModelContext.delete(model: MealLog.self, where: #Predicate { _ in true })
        try? mainModelContext.delete(model: FoodItemInMeal.self, where: #Predicate { _ in true })
        try? mainModelContext.delete(model: DailySummary.self, where: #Predicate { _ in true })
        try? mainModelContext.save()
    }
}
