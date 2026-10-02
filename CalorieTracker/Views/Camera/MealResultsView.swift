import SwiftUI

struct MealResultsView: View {
    @ObservedObject var viewModel: MealResultsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedMealType: MealType = .dinner
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    mealImageView

                    detectedFoodsSection

                    weightAdjustmentSection

                    nutritionBreakdown

                    actionButtons
                }
                .padding()
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Meal Analysis")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $viewModel.showError) {
                errorAlert
            }
        }
        .onAppear {
            Task {
                if viewModel.foodItems.isEmpty {
                    await viewModel.estimateWeights()
                    await viewModel.lookupNutrition()
                }
            }
        }
    }

    @ViewBuilder
    private var mealImageView: some View {
        Image(uiImage: viewModel.image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 200)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.dividerColor, lineWidth: 1)
            )
    }

    @ViewBuilder
    private var detectedFoodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detected Foods")
                .font(.headline)

            if viewModel.isCalculatingWeights && viewModel.detectedFoods.isEmpty {
                ProgressView("Analyzing...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(viewModel.detectedFoods) { food in
                    DetectedFoodCard(food: food, viewModel: viewModel)
                }
            }

            if viewModel.detectedFoods.isEmpty && !viewModel.isCalculatingWeights {
                Text("No foods detected. You can manually add items below.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryTextColor)
                    .multilineAlignment(.center)
                    .padding()
            }
        }
    }

    @ViewBuilder
    private var weightAdjustmentSection: some View {
        if !viewModel.foodItems.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Weights")
                    .font(.headline)

                ForEach(viewModel.foodItems) { item in
                    WeightAdjustmentView(
                        foodName: item.foodName,
                        weight: item.finalWeightG,
                        onWeightChange: { newWeight in
                            item.userAdjustedWeightG = newWeight
                            item.estimatedWeightG = newWeight
                        }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var nutritionBreakdown: some View {
        if !viewModel.foodItems.isEmpty {
            NutritionBreakdownCard(
                items: viewModel.foodItems,
                totals: viewModel.totalNutrition()
            )
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Picker("Meal Type", selection: $selectedMealType) {
                Text("Select Meal Type")
                ForEach(MealType.allCases) { type in
                    Label(type.rawValue, systemImage: type.icon)
                }
            }
            .pickerStyle(.segmented)

            TextField("Add a note (optional)", text: $notes, axis: .vertical)
                .padding(8)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)

            HStack(spacing: 16) {
                Button(action: { }) {
                    Label("Add Item", systemImage: "plus")
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.primaryColor)
                }

                Button(action: saveMeal) {
                    if viewModel.isSaving {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Save Meal")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primaryColor)
                .cornerRadius(AppTheme.buttonCornerRadius)
                .disabled(viewModel.isSaving || viewModel.foodItems.isEmpty)
            }
        }
    }

    @ViewBuilder
    private var errorAlert: some View {
        Alert(
            title: Text("Error"),
            message: Text(viewModel.errorMessage ?? "Something went wrong"),
            dismissButton: .default(Text("OK")) {
                viewModel.showError = false
            }
        )
    }

    private func saveMeal() {
        Task {
            let success = await viewModel.saveMeal(
                mealType: selectedMealType,
                notes: notes.isEmpty ? nil : notes
            )
            if success {
                dismiss()
            }
        }
    }
}

struct DetectedFoodCard: View {
    let food: DetectedFood
    let viewModel: MealResultsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(FoodClassMapper.getFoodName(for: food.className))
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                ConfidenceIndicator(confidence: food.confidence)
            }

            if let estimate = viewModel.weightEstimates[food.id.uuidString] {
                Text("\(Int(estimate.estimatedGrams))g · \(estimate.method.rawValue)")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }

            if let item = viewModel.foodItems.first(where: { $0.foodName.lowercased() == food.className.lowercased() || $0.foodDatabaseId == food.foodDatabaseId }) {
                WeightAdjustmentView(
                    foodName: item.foodName,
                    weight: item.finalWeightG,
                    onWeightChange: { newWeight in
                        item.userAdjustedWeightG = newWeight
                        item.estimatedWeightG = newWeight
                    }
                )
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.smallCornerRadius)
    }
}

struct NutritionBreakdownCard: View {
    let items: [FoodItemInMeal]
    let totals: (calories: Double, protein: Double, carbs: Double, fat: Double)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutrition Breakdown")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 20) {
                VStack(spacing: 8) {
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                    Text("\(Int(totals.calories))")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("kcal")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }

                VStack(alignment: .leading, spacing: 12) {
                    macroRow("Protein", value: totals.protein, unit: "g", color: .blue)
                    macroRow("Carbs", value: totals.carbs, unit: "g", color: .orange)
                    macroRow("Fat", value: totals.fat, unit: "g", color: .purple)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private func macroRow(_ name: String, value: Double, unit: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text("\(name): \(Int(value))\(unit)")
                .font(.subheadline)
                .foregroundColor(AppTheme.textColor)

            Spacer()
        }
    }
}
