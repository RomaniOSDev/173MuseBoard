import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    @Binding var selectedTab: Int

    @State private var selectedImage: MuseImage?
    @State private var selectedBoard: Board?
    @State private var showAddImage = false
    @State private var showCompare = false
    @State private var showSettings = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    if let featured = viewModel.featuredImage {
                        HomeHeroWidget(image: featured) {
                            selectedImage = featured
                        }
                        .padding(.horizontal, MuseDesign.horizontalPadding)
                    } else {
                        emptyHero
                    }

                    HomeStatsGridWidget(
                        total: viewModel.totalImages,
                        favorites: viewModel.favoriteCount,
                        saved: viewModel.savedCount,
                        boards: viewModel.boards.count
                    )
                    .padding(.horizontal, MuseDesign.horizontalPadding)

                    HomeQuickActionsWidget(
                        onAddPhoto: { showAddImage = true },
                        onOpenFeed: { selectedTab = 1 },
                        onOpenSaved: { selectedTab = 2 },
                        onCompare: { showCompare = true }
                    )
                    .padding(.horizontal, MuseDesign.horizontalPadding)

                    HomeStreakActivityWidget(
                        streak: viewModel.uploadStreak,
                        activity: viewModel.weeklyActivity
                    )
                    .padding(.horizontal, MuseDesign.horizontalPadding)

                    if let goal = viewModel.topStyleGoal {
                        HomeGoalWidget(
                            style: goal.style,
                            current: goal.current,
                            target: goal.target
                        )
                        .padding(.horizontal, MuseDesign.horizontalPadding)
                    }

                    HomeImageStripWidget(
                        title: "Recently Added",
                        subtitle: "Your latest inspiration",
                        images: Array(viewModel.recentImages.prefix(8)),
                        onSelect: { selectedImage = $0 },
                        onSeeAll: { selectedTab = 1 }
                    )
                    .padding(.horizontal, MuseDesign.horizontalPadding)

                    if !viewModel.favoriteImages.isEmpty {
                        HomeImageStripWidget(
                            title: "Favorites",
                            subtitle: "\(viewModel.favoriteCount) loved looks",
                            images: Array(viewModel.favoriteImages.prefix(8)),
                            onSelect: { selectedImage = $0 },
                            onSeeAll: { selectedTab = 2 }
                        )
                        .padding(.horizontal, MuseDesign.horizontalPadding)
                    }

                    if viewModel.recentImages.count >= 2 {
                        HomeMoodCollageWidget(images: Array(viewModel.recentImages.prefix(4)))
                            .padding(.horizontal, MuseDesign.horizontalPadding)
                    }

                    HomeBoardsWidget(
                        boards: viewModel.boards,
                        onSelect: { selectedBoard = $0 },
                        onSeeAll: { selectedTab = 3 }
                    )
                    .padding(.horizontal, MuseDesign.horizontalPadding)

                    HomeInsightTeaserWidget(
                        unlockedCount: viewModel.insights.count,
                        onOpen: { selectedTab = 5 }
                    )
                    .padding(.horizontal, MuseDesign.horizontalPadding)
                    .padding(.bottom, 24)
                }
                .padding(.top, 8)
            }
            .musePageBackground()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddImage) {
                AddImageView(viewModel: viewModel)
            }
            .sheet(item: $selectedImage) { image in
                NavigationStack {
                    ImageDetailView(viewModel: viewModel, image: image)
                }
            }
            .sheet(isPresented: $showCompare) {
                CompareView(viewModel: viewModel)
            }
            .navigationDestination(item: $selectedBoard) { board in
                BoardDetailView(viewModel: viewModel, board: board)
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.museDeep)
                Text(dateString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Your inspiration at a glance")
                    .font(.caption)
                    .foregroundColor(.museAccent)
            }

            Spacer()

            HStack(spacing: 10) {
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.museDeep)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .museShadow(.lite)
                        .overlay(Circle().stroke(Color.museSoftStroke.opacity(0.5), lineWidth: 1))
                }

                Button { showAddImage = true } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(MuseDesign.accentGradient)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        .museShadow(.elevated)
                }
            }
        }
        .padding(.horizontal, MuseDesign.horizontalPadding)
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var emptyHero: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.artframe")
                .font(.system(size: 48))
                .foregroundStyle(MuseDesign.accentGradient)

            Text("Start Your Board")
                .font(.title3.weight(.bold))
                .foregroundColor(.museDeep)

            Text("Add your first look to unlock widgets and inspiration tools.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button {
                showAddImage = true
            } label: {
                Text("Add First Photo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(MuseDesign.accentGradient)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .museCardSurface(shadow: .medium)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }
}
