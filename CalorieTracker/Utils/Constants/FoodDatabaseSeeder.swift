import Foundation

struct FoodDatabaseSeeder {
    static let seedData: [SeedEntry] = [
        SeedEntry(fdcId: "09003", name: "Apple", category: "Fruits", caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14, fatPer100g: 0.2, fiberPer100g: 2.4, sugarPer100g: 10, sodiumPer100g: 0, vitaminCPer100g: 4.6, vitaminAPer100g: 54, calciumPer100g: 6, ironPer100g: 0.1),
        SeedEntry(fdcId: "11027", name: "Edamame", category: "Vegetables", caloriesPer100g: 122, proteinPer100g: 11, carbsPer100g: 9.9, fatPer100g: 5.2, fiberPer100g: 5.2, sugarPer100g: 2.2, sodiumPer100g: 9, vitaminCPer100g: 6, vitaminAPer100g: 90, calciumPer100g: 63, ironPer100g: 2),
        SeedEntry(fdcId: "06008", name: "Hamburger", category: "Meat", caloriesPer100g: 250, proteinPer100g: 20, carbsPer100g: 17, fatPer100g: 10, fiberPer100g: 2.4, sugarPer100g: 3.5, sodiumPer100g: 380, vitaminCPer100g: 0, vitaminAPer100g: 18, calciumPer100g: 120, ironPer100g: 2.1),
        SeedEntry(fdcId: "03003", name: "Baby Back Ribs", category: "Meat", caloriesPer100g: 245, proteinPer100g: 22, carbsPer100g: 0, fatPer100g: 17, fiberPer100g: 0, sugarPer100g: 0, sodiumPer100g: 480, vitaminCPer100g: 0, vitaminAPer100g: 0, calciumPer100g: 14, ironPer100g: 2.7),
        SeedEntry(fdcId: "01996", name: "Apple Pie", category: "Desserts", caloriesPer100g: 237, proteinPer100g: 2.3, carbsPer100g: 34, fatPer100g: 9.8, fiberPer100g: 2.1, sugarPer100g: 16, sodiumPer100g: 240, vitaminCPer100g: 2.9, vitaminAPer100g: 5, calciumPer100g: 16, ironPer100g: 0.6),
        SeedEntry(fdcId: "07005", name: "Pasta Carbonara", category: "Pasta", caloriesPer100g: 170, proteinPer100g: 7.5, carbsPer100g: 18, fatPer100g: 8.2, fiberPer100g: 0.5, sugarPer100g: 0.5, sodiumPer100g: 400, vitaminCPer100g: 0, vitaminAPer100g: 45, calciumPer100g: 50, ironPer100g: 0.7),
        SeedEntry(fdcId: "07007", name: "Pizza", category: "Fast Food", caloriesPer100g: 266, proteinPer100g: 11, carbsPer100g: 34, fatPer100g: 10, fiberPer100g: 2.8, sugarPer100g: 3.2, sodiumPer100g: 590, vitaminCPer100g: 3.4, vitaminAPer100g: 120, calciumPer100g: 200, ironPer100g: 1.8),
        SeedEntry(fdcId: "06030", name: "French Fries", category: "Fast Food", caloriesPer100g: 312, proteinPer100g: 3.4, carbsPer100g: 33, fatPer100g: 16, fiberPer100g: 3.8, sugarPer100g: 0.6, sodiumPer100g: 312, vitaminCPer100g: 7.2, vitaminAPer100g: 0, calciumPer100g: 8, ironPer100g: 0.6),
        SeedEntry(fdcId: "07015", name: "Macaroni and Cheese", category: "Pasta", caloriesPer100g: 140, proteinPer100g: 7, carbsPer100g: 14, fatPer100g: 6.3, fiberPer100g: 0, sugarPer100g: 1.7, sodiumPer100g: 300, vitaminCPer100g: 0.9, vitaminAPer100g: 90, calciumPer100g: 100, ironPer100g: 0.4),
        SeedEntry(fdcId: "07029", name: "Caesar Salad", category: "Salads", caloriesPer100g: 165, proteinPer100g: 6.2, carbsPer100g: 7.5, fatPer100g: 12.4, fiberPer100g: 2.8, sugarPer100g: 2.4, sodiumPer100g: 430, vitaminCPer100g: 10, vitaminAPer100g: 170, calciumPer100g: 75, ironPer100g: 1.1),
        SeedEntry(fdcId: "02015", name: "Cinnamon Roll", category: "Bakery", caloriesPer100g: 382, proteinPer100g: 6.9, carbsPer100g: 51, fatPer100g: 15.7, fiberPer100g: 2.3, sugarPer100g: 20, sodiumPer100g: 360, vitaminCPer100g: 1.2, vitaminAPer100g: 0, calciumPer100g: 60, ironPer100g: 1.6),
        SeedEntry(fdcId: "01006", name: "Ice Cream", category: "Desserts", caloriesPer100g: 207, proteinPer100g: 3.4, carbsPer100g: 23.6, fatPer100g: 10.6, fiberPer100g: 0.4, sugarPer100g: 18.8, sodiumPer100g: 80, vitaminCPer100g: 0.3, vitaminAPer100g: 100, calciumPer100g: 100, ironPer100g: 0.2),
        SeedEntry(fdcId: "05006", name: "Orange Juice", category: "Beverages", caloriesPer100g: 45, proteinPer100g: 0.7, carbsPer100g: 11.1, fatPer100g: 0.2, fiberPer100g: 0.4, sugarPer100g: 9.4, sodiumPer100g: 2, vitaminCPer100g: 50, vitaminAPer100g: 225, calciumPer100g: 11, ironPer100g: 0.1),
        SeedEntry(fdcId: "02008", name: "French Toast", category: "Breakfast", caloriesPer100g: 287, proteinPer100g: 9.6, carbsPer100g: 33, fatPer100g: 12.9, fiberPer100g: 1.9, sugarPer100g: 4.8, sodiumPer100g: 520, vitaminCPer100g: 2.8, vitaminAPer100g: 290, calciumPer100g: 110, ironPer100g: 1.6),
        SeedEntry(fdcId: "07027", name: "Tuna Salad", category: "Salads", caloriesPer100g: 218, proteinPer100g: 15, carbsPer100g: 3.5, fatPer100g: 15.2, fiberPer100g: 1.3, sugarPer100g: 1.8, sodiumPer100g: 500, vitaminCPer100g: 2.4, vitaminAPer100g: 15, calciumPer100g: 40, ironPer100g: 1.0)
    ]

    struct SeedEntry {
        let fdcId: String
        let name: String
        let category: String
        let caloriesPer100g: Double
        let proteinPer100g: Double
        let carbsPer100g: Double
        let fatPer100g: Double
        let fiberPer100g: Double
        let sugarPer100g: Double
        let sodiumPer100g: Double
        let vitaminCPer100g: Double
        let vitaminAPer100g: Double
        let calciumPer100g: Double
        let ironPer100g: Double
    }
}
