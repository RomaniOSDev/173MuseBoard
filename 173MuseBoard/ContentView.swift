import SwiftUI

struct ContentView: View {
    @AppStorage(OnboardingStorage.completedKey) private var onboardingCompleted = false
    @StateObject private var viewModel = MuseBoardViewModel()
    @State private var selectedTab = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(red: 0.98, green: 0.99, blue: 1.0, alpha: 0.96)
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.06)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        Group {
            if onboardingCompleted {
                mainTabView
            } else {
                OnboardingView {
                    onboardingCompleted = true
                }
            }
        }
        .onAppear {
            viewModel.loadFromUserDefaults()
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            FeedView(viewModel: viewModel)
                .tabItem {
                    Label("Feed", systemImage: "photo.stack")
                }
                .tag(1)

            SavedView(viewModel: viewModel)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(2)

            BoardsView(viewModel: viewModel)
                .tabItem {
                    Label("Boards", systemImage: "square.grid.2x2.fill")
                }
                .tag(3)

            CollectionsView(viewModel: viewModel)
                .tabItem {
                    Label("Collections", systemImage: "folder.fill")
                }
                .tag(4)

            InsightsView(viewModel: viewModel)
                .tabItem {
                    Label("Insights", systemImage: "sparkles")
                }
                .tag(5)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }
                .tag(6)
        }
        .tint(.museAccent)
    }
}

#Preview {
    ContentView()
}
