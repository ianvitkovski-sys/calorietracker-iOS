import SwiftUI
import SwiftData

struct MealDetailView: View {
    @ObservedObject var viewModel: MealDetailViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    mealHeader

                    nutritionSummary

                    foodItemsList

                    notesSection
                }
                .padding()
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Meal Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.deleteMeal() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var mealHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.meal.mealType.rawValue)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(viewModel.meal.dateFormatted)
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryTextColor)

            HStack {
                Text("\(Int(viewModel.meal.totalCalories)) kcal")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(viewModel.meal.items.count) items")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }
        }
    }

    @ViewBuilder
    private var nutritionSummary: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Macronutrients")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 0) {
                macroColumn("Protein", value: "\(Int(viewModel.meal.totalProteinG))g", color: .blue)
                Divider()
                macroColumn("Carbs", value: "\(Int(viewModel.meal.totalCarbsG))g", color: .orange)
                Divider()
                macroColumn("Fat", value: "\(Int(viewModel.meal.totalFatG))g", color: .purple)
            }
            .frame(height: 80)

            microColumn("Fiber", value: "\(Int(viewModel.meal.totalFiberG))g", icon: "leaf")
            microColumn("Sugar", value: "\(Int(viewModel.meal.totalSugarG))g", icon: "drop.sparkles")
            microColumn("Sodium", value: "\(Int(viewModel.meal.totalSodiumG * 1000))mg", icon: "droplet")
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private func macroColumn(_ title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .textCase(.uppercase)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.secondaryTextColor)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func microColumn(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.secondaryTextColor)

            Text("\(title): \(value)")
                .font(.subheadline)
                .foregroundColor(AppTheme.textColor)

            Spacer()
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var foodItemsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.headline)

            ForEach(viewModel.meal.items) { item in
                FoodItemRowView(item: item)
            }
        }
    }

    @ViewBuilder
    private var notesSection: some View {
        if let notes = viewModel.meal.notes, !notes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.headline)
                    .foregroundColor(AppTheme.secondaryTextColor)

                Text(notes)
                    .font(.body)
            }
        }
    }
}
