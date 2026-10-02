import SwiftUI
import Foundation

struct AppTheme {
    static let primaryColor = Color(UIColor.systemGreen)
    static let secondaryColor = Color(UIColor.systemBlue)
    static let accentColor = Color(UIColor.systemTeal)
    static let backgroundColor = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let textColor = Color(UIColor.label)
    static let secondaryTextColor = Color(UIColor.secondaryLabel)

    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 12

    static let shadowColor = Color.black.opacity(0.08)
    static let shadowRadius: CGFloat = 8
    static let shadowYOffset: CGFloat = 4

    static let animationDuration: Double = 0.3
    static let quickAnimationDuration: Double = 0.15

    static let chartColors: [Color] = [
        Color(UIColor.systemGreen),
        Color(UIColor.systemBlue),
        Color(UIColor.systemOrange),
        Color(UIColor.systemPurple),
        Color(UIColor.systemTeal),
        Color(UIColor.systemRed)
    ]
}
