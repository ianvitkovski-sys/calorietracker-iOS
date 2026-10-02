import SwiftUI

struct NutritionBadgeView: View {
    let title: String
    let value: String
    let target: String
    let status: Status

    enum Status {
        case good, moderate, low, high

        var color: Color {
            switch self {
            case .good: return Color(UIColor.systemGreen)
            case .moderate: return Color(UIColor.systemOrange)
            case .low: return Color(UIColor.systemRed)
            case .high: return Color(UIColor.systemYellow)
            }
        }

        var icon: String {
            switch self {
            case .good: return "checkmark.circle.fill"
            case .moderate: return "exclamationmark.circle.fill"
            case .low: return "xmark.circle.fill"
            case .high: return "exclamationmark.triangle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName(status.icon)
                )
                .font(.title3)
                .foregroundColor(status.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Target: \(target)")
                    .font(.caption2)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(status.color)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(status.color.opacity(0.1))
        .cornerRadius(AppTheme.smallCornerRadius)
    }
}
