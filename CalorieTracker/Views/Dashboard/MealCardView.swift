import SwiftUI
import SwiftData

struct MealCardView: View {
    let meal: MealLog
    let action: () -> Void

    private var mealTypeColor: Color {
        switch meal.mealType {
        case .breakfast: return .yellow
        case .lunch: return .orange
        case .dinner: return .purple
        case .snack: return .pink
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(meal.mealType.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(mealTypeColor.opacity(0.2))
                        .foregroundColor(mealTypeColor)
                        .cornerRadius(6)

                    Spacer()

                    Text(meal.timeFormatted)
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }

                Text(meal.notes ?? "No notes")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textColor)
                    .lineLimit(2)

                HStack {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(meal.totalCalories)) kcal")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("\(Int(meal.totalProteinG))P · \(Int(meal.totalCarbsG))C · \(Int(meal.totalFatG))F")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryTextColor)
                    }

                    Spacer()

                    Text("\(meal.items.count) items")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }
                .padding(.top, 4)
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.smallCornerRadius)
        }
        .buttonStyle(.plain)
    }
}
