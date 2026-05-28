import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: MuseBoardViewModel

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    summaryGrid
                    streakSection
                    goalsSection
                    statPanel(title: "Popular Styles", stats: viewModel.styleStats.map {
                        MuseBoardViewModel.NamedStat(name: $0.name, icon: $0.icon, count: $0.count)
                    })
                    statPanel(title: "Top Moods", stats: viewModel.moodStats)
                    statPanel(title: "Top Locations", stats: viewModel.locationStats)
                    activityChartSection
                }
                .padding(.vertical, 8)
            }
            .musePageBackground()
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Total Photos", value: "\(viewModel.totalImages)", icon: "photo.fill", color: .museAccent)
            StatCard(title: "Favorites", value: "\(viewModel.favoriteCount)", icon: "heart.fill", color: .museAccent)
            StatCard(title: "Styles Used", value: "\(viewModel.usedStylesCount)", icon: "tag.fill", color: .museDeep)
            StatCard(title: "Collections", value: "\(viewModel.collections.count)", icon: "folder.fill", color: .museAccent)
        }
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private var streakSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(MuseDesign.accentGradient)
                    .frame(width: 56, height: 56)
                    .museShadow(.lite)
                Image(systemName: "flame.fill")
                    .foregroundColor(.white)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Upload Streak")
                    .font(.headline)
                    .foregroundColor(.museDeep)
                Text("Days in a row with new photos")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("\(viewModel.uploadStreak)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.museAccent)
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Style Goals")
                .font(.headline)
                .foregroundColor(.museDeep)

            ForEach(viewModel.styleGoals(), id: \.style) { goal in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: goal.style.icon)
                            .foregroundColor(.museAccent)
                        Text(goal.style.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.museDeep)
                        Spacer()
                        Text("\(goal.current)/\(goal.target)")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.museAccent))
                    }

                    ProgressView(value: Double(goal.current), total: Double(max(goal.target, 1)))
                        .tint(.museAccent)

                    Stepper(
                        "Target: \(viewModel.styleGoalTargets[goal.style] ?? 10)",
                        value: Binding(
                            get: { viewModel.styleGoalTargets[goal.style] ?? 10 },
                            set: { viewModel.setStyleGoalTarget($0, for: goal.style) }
                        ),
                        in: 1...50
                    )
                    .font(.caption)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.museSoftFill)
                )
            }
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private func statPanel(title: String, stats: [MuseBoardViewModel.NamedStat]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.museDeep)

            if stats.isEmpty {
                Text("No data yet — add more tagged photos.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(stats) { stat in
                    MuseStatRow(icon: stat.icon, name: stat.name, count: stat.count)
                }
            }
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private var activityChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Activity")
                .font(.headline)
                .foregroundColor(.museDeep)

            Chart {
                ForEach(viewModel.weeklyActivity) { data in
                    BarMark(
                        x: .value("Day", data.day),
                        y: .value("Photos", data.count)
                    )
                    .foregroundStyle(MuseDesign.accentGradient)
                    .cornerRadius(6)
                }
            }
            .frame(height: 160)
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
        .padding(.bottom, 16)
    }
}
