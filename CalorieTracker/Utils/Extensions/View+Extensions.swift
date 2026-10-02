import SwiftUI
import Foundation

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (AnyView) -> Content) -> some View {
        if condition {
            transform(AnyView(self))
        } else {
            self
        }
    }

    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, y: AppTheme.shadowYOffset)
    }

    func loadingState(_ isLoading: Bool) -> some View {
        self
            .disabled(isLoading)
            .blur(radius: isLoading ? 2 : 0)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                }
            }
    }
}
