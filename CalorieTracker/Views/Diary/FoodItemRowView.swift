import SwiftUI

struct FoodItemRowView: View {
    let item: FoodItemInMeal

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(item.confidenceColor.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(item.confidenceColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.foodName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Text(item.confidenceText)
                        .font(.caption2)
                        .foregroundColor(AppTheme.secondaryTextColor)

                    if let confidence = item.detectionConfidence {
                        Text("· \(Int(confidence * 100))% match")
                            .font(.caption2)
                            .foregroundColor(AppTheme.secondaryTextColor)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(item.calories)) kcal")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(item.finalWeightG.asGram())
                    .font(.caption2)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }
        }
        .padding(.vertical, 8)
    }
}
