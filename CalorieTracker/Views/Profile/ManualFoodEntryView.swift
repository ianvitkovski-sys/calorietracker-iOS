import SwiftUI

struct ManualFoodEntryView: View {
    @ObservedObject var viewModel: ManualEntryViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Search Food").textCase(.uppercase).font(.caption)) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.secondaryTextColor)
                        TextField("Search USDA database...", text: $viewModel.foodName, onEditingChanged: { _ in
                            if !viewModel.foodName.isEmpty {
                                viewModel.searchFoods(query: viewModel.foodName)
                            }
                        })
                    }

                    if viewModel.isSearching {
                        ProgressView("Searching...")
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(viewModel.searchResults) { entry in
                            Button(action: {
                                viewModel.selectFood(entry)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.name)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textColor)
                                    Text("\(Int(entry.caloriesPer100g)) kcal/100g · \(entry.category ?? "Uncategorized")")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.secondaryTextColor)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section(header: Text("Weight").textCase(.uppercase).font(.caption)) {
                    HStack {
                        TextField("Enter weight in grams", text: $viewModel.weightGrams)
                            .keyboardType(.decimalPad)
                        Text("g")
                    }
                }

                Section(header: Text("Meal Type").textCase(.uppercase).font(.caption)) {
                    Picker("Meal Type", selection: $viewModel.selectedMealType) {
                        Text("Select Meal Type")
                        ForEach(MealType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    TextField("Notes (optional)", text: $viewModel.notes)
                }

                if let info = viewModel.nutritionInfo {
                    Section(header: Text("Nutrition Preview")) {
                        nutritionRow("Calories", value: "\(Int(info.calories)) kcal")
                        nutritionRow("Protein", value: "\(info.protein.rounded())g")
                        nutritionRow("Carbs", value: "\(info.carbs.rounded())g")
                        nutritionRow("Fat", value: "\(info.fat.rounded())g")
                    }
                }

                Section {
                    Button("Save") {
                        Task {
                            let success = await viewModel.saveMeal()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.selectedFood == nil || viewModel.weightDouble == nil || viewModel.isSaving)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
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
        .onTapGesture {
            hideKeyboard()
        }
    }

    @ViewBuilder
    private func nutritionRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(AppTheme.secondaryTextColor)
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
