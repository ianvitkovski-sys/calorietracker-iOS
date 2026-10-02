import SwiftUI
import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([
            User.self,
            MealLog.self,
            FoodItemInMeal.self,
            FoodDatabaseEntry.self,
            DailySummary.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            localizedError: nil
        )

        do {
            if inMemory {
                container = try ModelContainer(
                    for: [
                        User.self,
                        MealLog.self,
                        FoodItemInMeal.self,
                        FoodDatabaseEntry.self,
                        DailySummary.self
                    ],
                    configurations: [configuration]
                )
            } else {
                container = try ModelContainer(for: configuration)
            }
        } catch {
            fatalError("Failed to create CoreData stack: \(error)")
        }
    }

    var viewContext: ModelContext {
        container.mainContext
    }

    var backgroundContext: ModelContext {
        container.mainContext
    }

    func save() {
        do {
            try viewContext.save()
        } catch {
            print("PersistenceController: Failed to save context: \(error)")
        }
    }

    func performBackgroundTask(_ block: @escaping (ModelContext) -> Void) {
        let context = ModelContext(container)
        block(context)
        save()
    }
}
