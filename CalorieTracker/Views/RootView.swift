import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: AppContainer
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                SplashView()
            } else if container.currentUser?.isProfileComplete == true {
                MainTabView()
            } else {
                ProfileSetupView(viewModel: ProfileSetupViewModel(container: container))
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isLoading = false
        }
    }
}

struct SplashView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "flame.fill")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.primaryColor)

            Text("CalorieTracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primaryColor)

            Text("AI-Powered Nutrition Tracking")
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard

    enum Tab: Int, CaseIterable, Identifiable {
        case dashboard, diary, camera, insights, profile

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .diary: return "Diary"
            case .camera: return "Camera"
            case .insights: return "Insights"
            case .profile: return "Profile"
            }
        }

        var icon: String {
            switch self {
            case .dashboard: return "gauge.badge.minus"
            case .diary: return "book.closed"
            case .camera: return "camera.viewfinder"
            case .insights: return "chart.line.uptrend.xyaxis"
            case .profile: return "person.crop.circle"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tag(Tab.dashboard)
            .tabItem { Image(systemName: Tab.dashboard.icon) }

            NavigationStack {
                FoodDiaryView()
            }
            .tag(Tab.diary)
            .tabItem { Image(systemName: Tab.diary.icon) }

            NavigationStack {
                CameraView()
            }
            .tag(Tab.camera)
            .tabItem { Image(systemName: Tab.camera.icon) }

            NavigationStack {
                InsightsView()
            }
            .tag(Tab.insights)
            .tabItem { Image(systemName: Tab.insights.icon) }

            NavigationStack {
                ProfileView()
            }
            .tag(Tab.profile)
            .tabItem { Image(systemName: Tab.profile.icon) }
        }
        .accentColor(AppTheme.primaryColor)
    }
}
