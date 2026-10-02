import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel(container: AppContainer.shared)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    profileHeader

                    bmiCard

                    dailyTargetsCard

                    waterTracking

                    quickStats

                    settingsSection
                }
                .padding()
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Profile")
        }
        .onAppear {
            viewModel.recalculate()
        }
    }

    @ViewBuilder
    private var profileHeader: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(AppTheme.primaryColor)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )

            Text(viewModel.user?.name ?? "Guest")
                .font(.title2)
                .fontWeight(.bold)

            if let age = viewModel.user?.age, let gender = viewModel.user?.gender {
                Text("\(age) · \(gender.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }

            if let goal = viewModel.user?.dietaryGoal {
                Label(goal.rawValue, systemImage: goal.icon)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.primaryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.primaryColor.opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var bmiCard: some View {
        VStack(spacing: 12) {
            Text("BMI")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            HStack(alignment: .firstBaseline, spacing: 4) {
                Text(viewModel.bmi?.rounded(to: 1).description ?? "N/A")
                    .font(.system(size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primaryColor)

                Text(viewModel.bmiCategory)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }

            if viewModel.progressToGoal > 0 {
                ProgressView(value: viewModel.progressToGoal)
                    .tint(AppTheme.primaryColor)

                Text("Progress to goal weight")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var dailyTargetsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Targets")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                    Text("\(viewModel.dailyCalories)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Protein")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                    Text("\(Int(viewModel.dailyProtein))g")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Carbs")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                    Text("\(Int(viewModel.dailyCarbs))g")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Fat")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                    Text("\(Int(viewModel.dailyFat))g")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var waterTracking: some View {
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

            HStack(spacing: 12) {
                Button("-250mL") {
                    viewModel.updateWaterIntake(max(0, viewModel.dailyWater - 250))
                }
                .font(.caption)
                .foregroundColor(.blue)

                Button("+250mL") {
                    viewModel.updateWaterIntake(viewModel.dailyWater + 250)
                }
                .font(.caption)
                .foregroundColor(.blue)

                Button("+500mL") {
                    viewModel.updateWaterIntake(viewModel.dailyWater + 500)
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var quickStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            HStack {
                statColumn("Height", value: viewModel.user?.heightCm.map { "\($0.rounded()) cm" } ?? "N/A")
                Divider().frame(width: 1)
                statColumn("Weight", value: viewModel.user?.currentWeightKg.map { "\($0.rounded()) kg" } ?? "N/A")
                Divider().frame(width: 1)
                statColumn("Goal", value: viewModel.user?.goalWeightKg.map { "\($0.rounded()) kg" } ?? "N/A")
            }
            .frame(height: 60)
        }
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private func statColumn(_ title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .textCase(.uppercase)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.secondaryTextColor)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)

            Button(action: { /* Edit profile */ }) {
                Label("Edit Profile", systemImage: "pencil")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textColor)
            }

            Button(action: { /* Diet preferences */ }) {
                Label("Dietary Preferences", systemImage: "list.bullet")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textColor)
            }

            Button(action: { /* Reminders */ }) {
                Label("Reminders", systemImage: "bell")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textColor)
            }

            Button(action: { /* About */ }) {
                Label("About", systemImage: "info.circle")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textColor)
            }

            Button("Reset All Data", role: .destructive) {
            }
            .font(.subheadline)
        }
        .padding()
        .cardStyle()
    }
}




