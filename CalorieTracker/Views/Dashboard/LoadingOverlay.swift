import SwiftUI

struct LoadingOverlay: View {
    let message: String
    let progress: Double?

    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .transition(.opacity)

        VStack(spacing: 16) {
            if let progress = progress {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .frame(width: 200)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }

            Text(message)
                .font(.callout)
                .foregroundColor(.white)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .padding()
    }
}

#Preview {
    LoadingOverlay(message: "Analyzing your meal...", progress: 0.5)
}
