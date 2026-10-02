import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel(container: AppContainer.shared)
    @State private var navigateToCamera = false
    @State private var selectedMeal: MealLog?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    calorieProgressSection

                    macroProgressSection

                    waterIntakeSection

                    quickAddSection

                    todaysMealsSection
                }
                .padding(.vertical)
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { navigateToCamera = true }) {
                        Image(systemName: "camera.viewfinder")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $navigateToCamera) {
                CameraView()
            }
            .sheet(item: $selectedMeal) { meal in
                MealDetailView(viewModel: MealDetailViewModel(meal: meal, container: viewModel.container ?? AppContainer.shared))
            }
        }
        .onAppear {
            Task { await viewModel.loadData() }
        }
    }

    @ViewBuilder
    private var calorieProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calories")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            HStack(alignment: .lastBaseline, spacing: 8) {
                Text("\(Int(viewModel.dailyCalories)) / \(viewModel.calorieTarget)")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                Text(viewModel.remainingCalories.asCalories())
                    .font(.subheadline)
                    .foregroundColor(viewModel.hasRemainingCalories ? .green : .red)
                    .fontWeight(.medium)
            }

            MacroRingView(
                progress: viewModel.calorieProgress,
                lineWidth: 12,
                color: viewModel.hasRemainingCalories ? AppTheme.primaryColor : .red,
                centerText: "\(Int(viewModel.calorieProgress * 100))%",
                centerFont: .title2
            )
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var macroProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macronutrients")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            MacroDonutChartView(
                protein: viewModel.dailyProtein,
                carbs: viewModel.dailyCarbs,
                fat: viewModel.dailyFat,
                targetProtein: viewModel.macroTargets.protein,
                targetCarbs: viewModel.macroTargets.carbs,
                targetFat: viewModel.macroTargets.fat
            )

            HStack(spacing: 0) {
                macroProgressRow("Protein", value: viewModel.dailyProtein, target: viewModel.macroTargets.protein, color: .blue, unit: "g")
                Divider().frame(width: 1)
                macroProgressRow("Carbs", value: viewModel.dailyCarbs, target: viewModel.macroTargets.carbs, color: .orange, unit: "g")
                Divider().frame(width: 1)
                macroProgressRow("Fat", value: viewModel.dailyFat, target: viewModel.macroTargets.fat, color: .purple, unit: "g")
            }
            .frame(height: 80)
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(AppTheme.smallCornerRadius)
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private func macroProgressRow(_ title: String, value: Double, target: Double, color: Color, unit: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .textCase(.uppercase)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.secondaryTextColor)

            Text("\(Int(value))\(unit)")
                .font(.subheadline)
                .fontWeight(.semibold)

            ProgressView(value: value, total: target > 0 ? target : 1)
                .tint(color)
                .progressViewStyle(.linear)

            Text("\(Int(target))\(unit)")
                .font(.caption2)
                .foregroundColor(AppTheme.secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var waterIntakeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Water")
                    .font(.headline)
                    .foregroundColor(AppTheme.secondaryTextColor)

                Spacer()

                Text("\(Int(viewModel.dailyWater)) / \(Int(viewModel.waterTarget)) mL")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }

            ProgressView(value: viewModel.waterProgress)
                .tint(.blue)

            HStack(spacing: 16) {
                Button(action: { viewModel.dailyWater = max(0, viewModel.dailyWater - 250) }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.blue)
                }

                Button(action: { viewModel.dailyWater += 250 }) {
                    Label("Add 250mL", systemImage: "drop.fill")
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }

                Spacer()

                Button(action: { viewModel.dailyWater += 500 }) {
                    Label("Add 500mL", systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var quickAddSection: some View {
        HStack(spacing: 16) {
            Button(action: { navigateToCamera = true }) {
                Label("Scan Meal", systemImage: "camera.viewfinder")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primaryColor)
                    .cornerRadius(AppTheme.buttonCornerRadius)
            }

            Button(action: { /* Navigate to manual entry */ }) {
                Label("Manual Entry", systemImage: "pencil")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primaryColor)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primaryColor.opacity(0.15))
                    .cornerRadius(AppTheme.buttonCornerRadius)
            }
        }
    }

    @ViewBuilder
    private var todaysMealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Meals")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            if viewModel.todaysMeals.isEmpty {
                Text("No meals logged today. Tap \"Scan Meal\" to get started!")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryTextColor)
                    .multilineAlignment(.center)
                    .padding()
            } else {
                ForEach(viewModel.todaysMeals) { meal in
                    MealCardView(meal: meal) {
                        selectedMeal = meal
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}




