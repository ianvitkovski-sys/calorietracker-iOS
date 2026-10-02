import SwiftUI

struct WeightAdjustmentView: View {
    let foodName: String
    @State var weight: Double
    var onWeightChange: (Double) -> Void

    @State private var sliderValue: Double
    @State private var manualEntry: String = ""
    @State private var showManualEntry = false

    init(foodName: String, weight: Double, onWeightChange: @escaping (Double) -> Void) {
        self.foodName = foodName
        self.weight = weight
        self.onWeightChange = onWeightChange
        self._sliderValue = State(initialValue: weight)
        self._manualEntry = State(initialValue: "\(Int(weight))")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(foodName)
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 8) {
                Text(sliderValue.asGram())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.primaryColor)
                    .frame(minWidth: 40)

                Slider(value: $sliderValue, in: AppConstants.minWeightGrams...AppConstants.maxWeightGrams, step: AppConstants.weightStepGrams) {
                    Text("Weight")
                }
                .accentColor(AppTheme.primaryColor)
                .onChange(of: sliderValue) { _, newValue in
                    manualEntry = "\(Int(newValue))"
                    onWeightChange(newValue)
                }

                Button(action: {
                    manualEntry = "\(Int(sliderValue))"
                    showManualEntry = true
                }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showManualEntry) {
            NavigationStack {
                VStack(spacing: 24) {
                    TextField("Enter weight in grams", text: $manualEntry)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    Text("Grams")
                        .font(.headline)
                        .foregroundColor(AppTheme.secondaryTextColor)

                    Spacer()
                }
                .navigationTitle("Adjust Weight")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { showManualEntry = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            if let value = Double(manualEntry) {
                                sliderValue = value
                                onWeightChange(value)
                            }
                            showManualEntry = false
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    WeightAdjustmentView(foodName: "Hamburger", weight: 150, onWeightChange: { _ in })
}
