import SwiftUI

struct ConfidenceIndicator: View {
    let confidence: Double

    private var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.8...1.0: return .high
        case 0.5..<0.8: return .medium
        default: return .low
        }
    }

    private var confidenceText: String {
        "\(Int(confidence * 100))%"
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(confidenceLevel.color)
                .frame(width: 8, height: 8)

            Text(confidenceText)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(confidenceLevel.color)

            Text(confidenceLevel.description)
                .font(.caption3)
                .foregroundColor(AppTheme.secondaryTextColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(confidenceLevel.color.opacity(0.15))
        .cornerRadius(6)
    }

    enum ConfidenceLevel {
        case high, medium, low

        var color: Color {
            switch self {
            case .high: return Color(UIColor.systemGreen)
            case .medium: return Color(UIColor.systemOrange)
            case .low: return Color(UIColor.systemRed)
            }
        }

        var description: String {
            switch self {
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            }
        }
    }
}
