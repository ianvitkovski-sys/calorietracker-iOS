import SwiftUI

struct ProfileSetupView: View {
    @StateObject var viewModel: ProfileSetupViewModel
    @EnvironmentObject var container: AppContainer

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Full Name", text: $viewModel.name)

                    Picker("Gender", selection: Binding(
                        get: { viewModel.gender ?? .male },
                        set: { viewModel.gender = $0 }
                    )) {
                        Text("Select Gender")
                        ForEach(Gender.allCases) { gender in
                            Label(gender.rawValue, systemImage: gender == .male ? "male" : gender == .female ? "female" : "person")
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section(header: Text("Physical Stats")) {
                    TextField("Height (cm)", text: $viewModel.height)
                        .keyboardType(.decimalPad)
                    TextField("Weight (kg)", text: $viewModel.weight)
                        .keyboardType(.decimalPad)
                    TextField("Goal Weight (kg)", text: $viewModel.goalWeight)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Date of Birth")) {
                    DatePicker("Select Date of Birth", selection: Binding(
                        get: { viewModel.dateOfBirth ?? Date() },
                        set: { viewModel.dateOfBirth = $0 }
                    ), displayedComponents: .date)
                }

                Section(header: Text("Activity Level")) {
                    Picker("Activity Level", selection: $viewModel.activityLevel) {
                        Text("Select Activity Level")
                        ForEach(ActivityLevel.allCases) { level in
                            VStack(alignment: .leading) {
                                Text(level.rawValue)
                                Text(level.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section(header: Text("Dietary Goal")) {
                    Picker("Dietary Goal", selection: $viewModel.dietaryGoal) {
                        ForEach(DietaryGoal.allCases) { goal in
                            Label(goal.rawValue, systemImage: goal.icon)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommended Calories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.recommendedCalories) kcal/day")
                            .font(.headline)
                            .foregroundColor(AppTheme.primaryColor)
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Button(action: {
                        Task {
                            let success = await viewModel.saveProfile()
                            if success {
                                container.currentUser?.isProfileComplete = true
                                try? container.mainModelContext.save()
                            }
                        }
                    }) {
                        if viewModel.isSaving {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text("Save Profile")
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSaving)
                }
            }
            .navigationTitle("Profile Setup")
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("OK") { }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView(viewModel: ProfileSetupViewModel(container: AppContainer.shared))
            .environmentObject(AppContainer.shared)
    }
}
