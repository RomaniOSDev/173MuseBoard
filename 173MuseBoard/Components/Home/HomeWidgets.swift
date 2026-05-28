import SwiftUI
import Charts

// MARK: - Hero

struct HomeHeroWidget: View {
    let image: MuseImage
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                MusePhotoView(imageName: image.primaryImageName, contentMode: .fill)
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.15), Color.black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack {
                    HStack {
                        Text("Featured Look")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.museAccent.opacity(0.9)))
                        Spacer()
                        if image.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Circle().fill(Color.museAccent))
                        }
                    }
                    .padding(14)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(image.title)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    HStack(spacing: 8) {
                        Label(image.mood.rawValue, systemImage: image.mood.icon)
                        if let occasion = image.occasion {
                            Label(occasion.rawValue, systemImage: occasion.icon)
                        }
                    }
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white.opacity(0.95))
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous))
            .museShadow(.elevated)
            .museGradientBorder()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stats grid

struct HomeStatsGridWidget: View {
    let total: Int
    let favorites: Int
    let saved: Int
    let boards: Int

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            HomeMiniStatCell(title: "Looks", value: "\(total)", icon: "photo.stack.fill", color: .museAccent)
            HomeMiniStatCell(title: "Favorites", value: "\(favorites)", icon: "heart.fill", color: .museAccent)
            HomeMiniStatCell(title: "Saved", value: "\(saved)", icon: "bookmark.fill", color: .museDeep)
            HomeMiniStatCell(title: "Boards", value: "\(boards)", icon: "square.grid.2x2.fill", color: .museDeep)
        }
    }
}

struct HomeMiniStatCell: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.museDeep)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .museElevatedShell(shadow: .lite)
        .overlay(
            RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Quick actions

struct HomeQuickActionsWidget: View {
    var onAddPhoto: () -> Void
    var onOpenFeed: () -> Void
    var onOpenSaved: () -> Void
    var onCompare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.museDeep)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                HomeQuickActionCell(title: "Add Photo", icon: "plus.circle.fill", gradient: true, action: onAddPhoto)
                HomeQuickActionCell(title: "Browse Feed", icon: "rectangle.grid.2x2.fill", action: onOpenFeed)
                HomeQuickActionCell(title: "Saved", icon: "bookmark.fill", action: onOpenSaved)
                HomeQuickActionCell(title: "Compare", icon: "square.split.2x1.fill", action: onCompare)
            }
        }
        .museCardSurface(shadow: .lite)
    }
}

struct HomeQuickActionCell: View {
    let title: String
    let icon: String
    var gradient: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(gradient ? .white : .museAccent)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(gradient ? .white : .museDeep)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(
                Group {
                    if gradient {
                        MuseDesign.accentGradient
                    } else {
                        Color.museSoftFill
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                    .stroke(
                        gradient
                            ? Color.white.opacity(0.35)
                            : Color.museSoftStroke.opacity(0.5),
                        lineWidth: gradient ? 0.5 : 1
                    )
            )
            .museShadow(gradient ? .lite : .none)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Image strip

struct HomeImageStripWidget: View {
    let title: String
    let subtitle: String
    let images: [MuseImage]
    var onSelect: (MuseImage) -> Void
    var onSeeAll: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.museDeep)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                if let onSeeAll {
                    Button("See All", action: onSeeAll)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.museAccent)
                }
            }

            if images.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No photos yet")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                        .fill(Color.museSoftFill)
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(images) { image in
                            HomeImageTile(image: image) {
                                onSelect(image)
                            }
                        }
                    }
                }
            }
        }
        .museCardSurface(shadow: .lite)
    }
}

struct HomeImageTile: View {
    let image: MuseImage
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    MusePhotoView(imageName: image.primaryImageName, contentMode: .fill)
                        .frame(width: 130, height: 160)
                        .clipped()

                    if image.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Circle().fill(Color.museAccent))
                            .padding(8)
                    }
                }

                Text(image.title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.museDeep)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .frame(width: 130, alignment: .leading)
                    .background(Color.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .museShadow(.lite)
            .museGradientBorder(radius: 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Boards preview

struct HomeBoardsWidget: View {
    let boards: [Board]
    var onSelect: (Board) -> Void
    var onSeeAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Boards")
                    .font(.headline)
                    .foregroundColor(.museDeep)
                Spacer()
                Button("See All", action: onSeeAll)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.museAccent)
            }

            if boards.isEmpty {
                Text("Create a board to organize inspiration.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(boards.prefix(6)) { board in
                            HomeBoardTile(board: board) { onSelect(board) }
                        }
                    }
                }
            }
        }
        .museCardSurface(shadow: .lite)
    }
}

struct HomeBoardTile: View {
    let board: Board
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                MusePhotoView(imageName: board.coverImageName, contentMode: .fill)
                    .frame(width: 140, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(board.name)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.museDeep)
                    .lineLimit(1)

                Text("\(board.imageIds.count) photos")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(width: 140, alignment: .leading)
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous))
            .museShadow(.lite)
            .museGradientBorder(radius: MuseDesign.cellRadius)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Streak & activity

struct HomeStreakActivityWidget: View {
    let streak: Int
    let activity: [MuseBoardViewModel.WeeklyActivity]

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Streak")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.museDeep)
                }
                Text("\(streak)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.museAccent)
                Text(streak == 1 ? "day active" : "days active")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(width: 110)

            VStack(alignment: .leading, spacing: 8) {
                Text("This Week")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.museDeep)

                Chart {
                    ForEach(activity) { item in
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(Color.museAccent.opacity(0.85))
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 72)
            }
        }
        .museCardSurface(shadow: .lite)
    }
}

// MARK: - Goal widget

struct HomeGoalWidget: View {
    let style: StyleCategory
    let current: Int
    let target: Int

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(1, Double(current) / Double(target))
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.museSoftFill, lineWidth: 6)
                    .frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(MuseDesign.accentGradient, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                Image(systemName: style.icon)
                    .foregroundColor(.museAccent)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Style Goal")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                Text(style.rawValue)
                    .font(.headline)
                    .foregroundColor(.museDeep)
                Text("\(current) of \(target) looks")
                    .font(.caption)
                    .foregroundColor(.museAccent)
                ProgressView(value: progress)
                    .tint(.museAccent)
            }
        }
        .museCardSurface(shadow: .lite)
    }
}

// MARK: - Mood collage widget

struct HomeMoodCollageWidget: View {
    let images: [MuseImage]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Board Preview")
                .font(.headline)
                .foregroundColor(.museDeep)

            if images.count >= 4 {
                let slice = Array(images.prefix(4))
                HStack(spacing: 4) {
                    MusePhotoView(imageName: slice[0].primaryImageName, contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(spacing: 4) {
                        MusePhotoView(imageName: slice[1].primaryImageName, contentMode: .fill)
                            .frame(height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        MusePhotoView(imageName: slice[2].primaryImageName, contentMode: .fill)
                            .frame(height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .frame(width: 90)
                }
                .overlay(alignment: .bottomTrailing) {
                    MusePhotoView(imageName: slice[3].primaryImageName, contentMode: .fill)
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .padding(8)
                }
            } else if let first = images.first {
                MusePhotoView(imageName: first.primaryImageName, contentMode: .fill)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .museCardSurface(shadow: .lite)
    }
}

// MARK: - Insights teaser

struct HomeInsightTeaserWidget: View {
    let unlockedCount: Int
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(MuseDesign.accentGradient)
                        .frame(width: 52, height: 52)
                    Image(systemName: "sparkles")
                        .foregroundColor(.white)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Style Insights")
                        .font(.headline)
                        .foregroundColor(.museDeep)
                    Text("\(unlockedCount) styles unlocked — tap for tips")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.museAccent)
            }
        }
        .buttonStyle(.plain)
        .museCardSurface(shadow: .lite)
    }
}
