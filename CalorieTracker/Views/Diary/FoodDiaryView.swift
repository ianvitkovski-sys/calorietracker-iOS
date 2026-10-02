import SwiftUI

struct FoodDiaryView: View {
    @StateObject private var viewModel = FoodDiaryViewModel(container: AppContainer.shared)

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                dateSelector
                    .padding(.horizontal)

                Divider()

                List {
                    if viewModel.mealsForSelectedDate.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(viewModel.mealsForSelectedDate) { meal in
                            MealCardView(meal: meal) {
                            }
                            .listRowSeparator(.hidden)
                            .id(meal.id)
                        }
                    }
                }
                .listStyle(.insetGroup)

                summarySection
                    .padding()
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Food Diary")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            Task { await viewModel.loadData() }
        }
    }

    @ViewBuilder
    private var dateSelector: some View {
        HStack(spacing: 16) {
            Button(action: viewModel.previousDay) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundColor(AppTheme.primaryColor)
            }

            Button(action: viewModel.goToToday) {
                VStack(spacing: 4) {
                    Text(calendar.shortMonthSymbols[calendar.component(.month, from: viewModel.selectedDate) - 1])
                        .font(.headline)

                    Text("\(calendar.component(.day, from: viewModel.selectedDate)) \(calendar.component(.year, from: viewModel.selectedDate))")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }
            }
            .foregroundColor(AppTheme.textColor)

            Button(action: viewModel.nextDay) {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(AppTheme.primaryColor)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.secondaryTextColor.opacity(0.5))

            Text("No meals logged")
                .font(.headline)
                .foregroundColor(AppTheme.textColor)

            Text("Tap the camera to scan a meal")
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private var summarySection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Daily Summary")
                    .font(.headline)
                Spacer()
                Text("\(Int(viewModel.todaysTotalCalories)) kcal")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primaryColor)
            }

            HStack(spacing: 0) {
                summaryStat("Protein", value: "\(Int(viewModel.todaysTotalProtein))g", color: .blue)
                Divider().frame(height: 24)
                summaryStat("Carbs", value: "\(Int(viewModel.todaysTotalCarbs))g", color: .orange)
                Divider().frame(height: 24)
                summaryStat("Fat", value: "\(Int(viewModel.todaysTotalFat))g", color: .purple)
            }
            .frame(height: 44)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .padding(.top)
    }

    @ViewBuilder
    private func summaryStat(_ title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .textCase(.uppercase)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.secondaryTextColor)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}
