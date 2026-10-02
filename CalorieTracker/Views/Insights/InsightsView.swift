import SwiftUI
import Charts

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel(container: AppContainer.shared)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    periodSelector

                    calorieSummaryCard

                    weeklyTrendChart

                    macroDistributionCard

                    nutrientInsights
                }
                .padding()
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Insights")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    @ViewBuilder
    private var periodSelector: some View {
        Picker("Period", selection: $viewModel.selectedPeriod) {
            ForEach(InsightsViewModel.InsightsPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var calorieSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Average Daily Calories")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            Text("\(Int(viewModel.averageDailyCalories))")
                .font(.system(size: 48))
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primaryColor)

            HStack(spacing: 4) {
                Image(systemName(trendIcon))
                    .foregroundColor(trendColor)

                Text(trendText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(trendColor)
            }
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var weeklyTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trend")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            Chart {
                ForEach(viewModel.weeklyData, id: \.date) { summary in
                    LineMark(
                        x: .value("Day", summary.date, unit: .day),
                        y: .value("Calories", summary.totalCalories)
                    )
                    .foregroundStyle(AppTheme.primaryColor)
                    .interpolationCurve(.catmullRom)

                    BarMark(
                        x: .value("Day", summary.date, unit: .day),
                        y: .value("Calories", summary.totalCalories)
                    )
                    .foregroundStyle(AppTheme.primaryColor.opacity(0.6))
                }
            }
            .chartYScale(domain: 0...(viewModel.weeklyData.map(\.totalCalories).max() ?? 2000) * 1.2)
            .chartXScale(domain: 0...1)
            .frame(height: 180)
            .chartXAxisLabel("Daily Intake", position: .bottom, alignment: .center)
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var macroDistributionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macro Distribution")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            HStack(alignment: .bottom, spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.averageDailyProtein))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Protein (g)")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }

                VStack(spacing: 4) {
                    Text("\(Int(viewModel.averageDailyCarbs))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Carbs (g)")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }

                VStack(spacing: 4) {
                    Text("\(Int(viewModel.averageDailyFat))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Fat (g)")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var nutrientInsights: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrient Insights")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            if viewModel.weeklyData.isEmpty || viewModel.totalCaloriesInPeriod == 0 {
                Text("No data yet. Start logging meals to see insights!")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryTextColor)
                    .multilineAlignment(.center)
                    .padding()
            } else {
                NutritionBadgeView(
                    title: "Daily Fiber",
                    value: "\(viewModel.averageDailyProtein)g",
                    target: "25-30g",
                    status: .good
                )
                NutritionBadgeView(
                    title: "Daily Sugar",
                    value: "\(viewModel.averageDailyCarbs)g",
                    target: "< 50g",
                    status: .moderate
                )
            }
        }
        .padding()
        .cardStyle()
    }

    private var trendIcon: String {
        switch viewModel.calorieTrendDirection {
        case .increasing: return "arrow.up.right"
        case .decreasing: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }

    private var trendColor: Color {
        switch viewModel.calorieTrendDirection {
        case .increasing: return .red
        case .decreasing: return .green
        case .stable: return AppTheme.secondaryTextColor
        }
    }

    private var trendText: String {
        switch viewModel.calorieTrendDirection {
        case .increasing: return "Above last week"
        case .decreasing: return "Below last week"
        case .stable: return "Same as last week"
        }
    }
}



