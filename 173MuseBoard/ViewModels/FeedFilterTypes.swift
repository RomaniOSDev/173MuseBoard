import Foundation

enum FeedLibraryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case favorites = "Favorites"
    case saved = "Saved"

    var id: String { rawValue }
}

enum FeedSortOption: String, CaseIterable, Identifiable {
    case dateNewest = "Newest"
    case dateOldest = "Oldest"
    case titleAZ = "Title A–Z"
    case titleZA = "Title Z–A"
    case styleCount = "Most Styles"

    var id: String { rawValue }
}

struct StyleGoalProgress: Identifiable, Codable, Equatable {
    let style: StyleCategory
    var target: Int

    var id: String { style.rawValue }

    func currentCount(in images: [MuseImage]) -> Int {
        images.filter { $0.styles.contains(style) }.count
    }

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(1, Double(currentCount(in: [])) / Double(target))
    }
}
