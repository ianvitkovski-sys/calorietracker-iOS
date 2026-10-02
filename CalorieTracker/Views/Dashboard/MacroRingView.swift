import SwiftUI

struct MacroRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    let centerText: String
    let centerFont: Font

    private var clampedProgress: Double {
        max(0, min(1, progress))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(UIColor.systemGray5), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineCorner: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: clampedProgress)

            Text(centerText)
                .font(centerFont)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textColor)
        }
        .frame(height: 120)
    }
}

#Preview {
    MacroRingView(progress: 0.65, lineWidth: 12, color: .green, centerText: "65%", centerFont: .title2)
}
