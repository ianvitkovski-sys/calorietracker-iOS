import Foundation
import SwiftUI

// MARK: - Launch Screen Placeholder
// The LaunchScreen.storyboard is referenced in Info.plist
// Create a simple launch screen in the Assets.xcassets or as a storyboard

struct LaunchScreenView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primaryColor)
            Text("CalorieTracker")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primaryColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
}
