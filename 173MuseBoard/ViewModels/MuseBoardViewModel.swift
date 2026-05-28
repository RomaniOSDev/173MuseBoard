import Foundation
import Combine

@MainActor
final class MuseBoardViewModel: ObservableObject {
    @Published var images: [MuseImage] = []
    @Published var boards: [Board] = []
    @Published var collections: [Collection] = []
    @Published var insights: [StyleInsight] = []
    @Published var notes: [PersonalNote] = []
    @Published var selectedStyle: StyleCategory?
    @Published var selectedMood: Mood?
    @Published var selectedOccasion: Occasion?
    @Published var searchText = ""
    @Published var libraryFilter: FeedLibraryFilter = .all
    @Published var feedSort: FeedSortOption = .dateNewest
    @Published var checkedTipKeys: Set<String> = []
    @Published var styleGoalTargets: [StyleCategory: Int] = [:]

    var totalImages: Int { images.count }
    var favoriteCount: Int { images.filter(\.isFavorite).count }
    var savedCount: Int { images.filter(\.isSaved).count }

    var usedStylesCount: Int {
        Set(images.flatMap(\.styles)).count
    }

    var allTags: [String] {
        Array(Set(images.flatMap(\.tags))).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var filteredImages: [MuseImage] {
        sortImages(applyFilters(to: images))
    }

    var savedImages: [MuseImage] {
        sortImages(images.filter(\.isSaved))
    }

    var recentImages: [MuseImage] {
        images.sorted { $0.createdAt > $1.createdAt }
    }

    var favoriteImages: [MuseImage] {
        images.filter(\.isFavorite).sorted { $0.createdAt > $1.createdAt }
    }

    var featuredImage: MuseImage? {
        favoriteImages.first ?? recentImages.first
    }

    var topStyleGoal: (style: StyleCategory, target: Int, current: Int)? {
        styleGoals()
            .filter { $0.current < $0.target }
            .sorted { ($0.current / max($0.target, 1)) > ($1.current / max($1.target, 1)) }
            .first
    }

    struct StyleStat: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let count: Int
    }

    struct NamedStat: Identifiable {
        let name: String
        let icon: String
        let count: Int
        var id: String { name }
    }

    var styleStats: [StyleStat] {
        let grouped = Dictionary(grouping: images.flatMap(\.styles), by: { $0 })
        return grouped.map { style, occurrences in
            StyleStat(name: style.rawValue, icon: style.icon, count: occurrences.count)
        }.sorted { $0.count > $1.count }
    }

    var moodStats: [NamedStat] {
        Dictionary(grouping: images, by: \.mood)
            .map { mood, items in
                NamedStat(name: mood.rawValue, icon: mood.icon, count: items.count)
            }
            .sorted { $0.count > $1.count }
    }

    var locationStats: [NamedStat] {
        let withLocation = images.compactMap { image -> (String, MuseImage)? in
            guard let location = image.location, !location.isEmpty else { return nil }
            return (location, image)
        }
        return Dictionary(grouping: withLocation, by: { $0.0 })
            .map { location, pairs in
                NamedStat(name: location, icon: "location.fill", count: pairs.count)
            }
            .sorted { $0.count > $1.count }
    }

    var uploadStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var day = calendar.startOfDay(for: Date())
        let creationDays = Set(images.map { calendar.startOfDay(for: $0.createdAt) })
        while creationDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    struct WeeklyActivity: Identifiable {
        let id = UUID()
        let day: String
        let count: Int
    }

    var weeklyActivity: [WeeklyActivity] {
        let calendar = Calendar.current
        let today = Date()
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }.reversed()
        return weekDays.map { date in
            let count = images.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }.count
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            formatter.locale = Locale(identifier: "en_US")
            return WeeklyActivity(day: formatter.string(from: date), count: count)
        }
    }

    func styleGoals() -> [(style: StyleCategory, target: Int, current: Int)] {
        StyleCategory.allCases.compactMap { style in
            let target = styleGoalTargets[style] ?? 10
            let current = images.filter { $0.styles.contains(style) }.count
            return (style, target, current)
        }
    }

    func tipKey(style: StyleCategory, tipIndex: Int) -> String {
        "\(style.rawValue)|\(tipIndex)"
    }

    func isTipChecked(style: StyleCategory, tipIndex: Int) -> Bool {
        checkedTipKeys.contains(tipKey(style: style, tipIndex: tipIndex))
    }

    func toggleTip(style: StyleCategory, tipIndex: Int) {
        let key = tipKey(style: style, tipIndex: tipIndex)
        if checkedTipKeys.contains(key) {
            checkedTipKeys.remove(key)
        } else {
            checkedTipKeys.insert(key)
        }
        saveToUserDefaults()
    }

    func image(with id: UUID) -> MuseImage? {
        images.first { $0.id == id }
    }

    func images(for board: Board) -> [MuseImage] {
        board.imageIds.compactMap { image(with: $0) }
    }

    func images(for collection: Collection) -> [MuseImage] {
        collection.imageIds.compactMap { image(with: $0) }
    }

    func collectionCoverName(for collection: Collection) -> String {
        if let cover = collection.coverImageName {
            return cover
        }
        if let firstId = collection.imageIds.first,
           let image = image(with: firstId) {
            return image.primaryImageName
        }
        return "girl1"
    }

    func notes(for imageId: UUID) -> [PersonalNote] {
        notes.filter { $0.imageId == imageId }.sorted { $0.createdAt > $1.createdAt }
    }

    func addImage(_ image: MuseImage) {
        images.append(image)
        updateInsights()
        saveToUserDefaults()
    }

    func updateImage(_ image: MuseImage) {
        if let index = images.firstIndex(where: { $0.id == image.id }) {
            var updated = image
            updated.updatedAt = Date()
            images[index] = updated
            updateInsights()
            saveToUserDefaults()
        }
    }

    func deleteImage(_ image: MuseImage) {
        MuseImageStorage.deleteAllLocal(names: image.imageNames)
        images.removeAll { $0.id == image.id }
        notes.removeAll { $0.imageId == image.id }
        for index in boards.indices {
            boards[index].imageIds.removeAll { $0 == image.id }
        }
        for index in collections.indices {
            collections[index].imageIds.removeAll { $0 == image.id }
        }
        updateInsights()
        saveToUserDefaults()
    }

    func duplicateImage(_ image: MuseImage) {
        let newId = UUID()
        let copiedNames = MuseImageStorage.copyImageNames(image.imageNames, to: newId)
        let copy = MuseImage(
            id: newId,
            imageNames: copiedNames,
            title: "\(image.title) (Copy)",
            description: image.description,
            styles: image.styles,
            mood: image.mood,
            occasion: image.occasion,
            tags: image.tags,
            photographer: image.photographer,
            location: image.location,
            dateTaken: image.dateTaken,
            isFavorite: false,
            isSaved: false,
            createdAt: Date(),
            updatedAt: nil
        )
        addImage(copy)
    }

    func toggleFavorite(_ image: MuseImage) {
        guard let index = images.firstIndex(where: { $0.id == image.id }) else { return }
        images[index].isFavorite.toggle()
        saveToUserDefaults()
    }

    func toggleSaved(_ image: MuseImage) {
        guard let index = images.firstIndex(where: { $0.id == image.id }) else { return }
        images[index].isSaved.toggle()
        saveToUserDefaults()
    }

    func addBoard(_ board: Board) {
        boards.append(board)
        saveToUserDefaults()
    }

    func updateBoard(_ board: Board) {
        if let index = boards.firstIndex(where: { $0.id == board.id }) {
            let oldCover = boards[index].coverImageName
            boards[index] = board
            if MuseImageStorage.isLocal(oldCover),
               oldCover != board.coverImageName {
                MuseImageStorage.deleteBoardCoverIfLocal(named: oldCover)
            }
            saveToUserDefaults()
        }
    }

    func deleteBoard(_ board: Board) {
        if MuseImageStorage.isLocal(board.coverImageName) {
            MuseImageStorage.deleteBoardCoverIfLocal(named: board.coverImageName)
        }
        boards.removeAll { $0.id == board.id }
        saveToUserDefaults()
    }

    func addImageToBoard(imageId: UUID, boardId: UUID) {
        guard let index = boards.firstIndex(where: { $0.id == boardId }),
              !boards[index].imageIds.contains(imageId) else { return }
        boards[index].imageIds.append(imageId)
        saveToUserDefaults()
    }

    func moveBoardImage(boardId: UUID, from source: IndexSet, to destination: Int) {
        guard let index = boards.firstIndex(where: { $0.id == boardId }) else { return }
        moveIds(&boards[index].imageIds, fromOffsets: source, toOffset: destination)
        saveToUserDefaults()
    }

    func removeImageFromBoard(imageId: UUID, boardId: UUID) {
        guard let index = boards.firstIndex(where: { $0.id == boardId }) else { return }
        boards[index].imageIds.removeAll { $0 == imageId }
        saveToUserDefaults()
    }

    func addCollection(_ collection: Collection) {
        collections.append(collection)
        saveToUserDefaults()
    }

    func updateCollection(_ collection: Collection) {
        if let index = collections.firstIndex(where: { $0.id == collection.id }) {
            collections[index] = collection
            saveToUserDefaults()
        }
    }

    func deleteCollection(_ collection: Collection) {
        collections.removeAll { $0.id == collection.id }
        saveToUserDefaults()
    }

    func addImageToCollection(imageId: UUID, collectionId: UUID) {
        guard let index = collections.firstIndex(where: { $0.id == collectionId }),
              !collections[index].imageIds.contains(imageId) else { return }
        collections[index].imageIds.append(imageId)
        saveToUserDefaults()
    }

    func moveCollectionImage(collectionId: UUID, from source: IndexSet, to destination: Int) {
        guard let index = collections.firstIndex(where: { $0.id == collectionId }) else { return }
        moveIds(&collections[index].imageIds, fromOffsets: source, toOffset: destination)
        saveToUserDefaults()
    }

    func addNote(_ note: PersonalNote) {
        notes.append(note)
        saveToUserDefaults()
    }

    func updateNote(_ note: PersonalNote) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveToUserDefaults()
        }
    }

    func deleteNote(_ note: PersonalNote) {
        notes.removeAll { $0.id == note.id }
        saveToUserDefaults()
    }

    func setStyleGoalTarget(_ target: Int, for style: StyleCategory) {
        styleGoalTargets[style] = max(1, target)
        saveToUserDefaults()
    }

    private func applyFilters(to source: [MuseImage]) -> [MuseImage] {
        var result = source

        switch libraryFilter {
        case .all: break
        case .favorites: result = result.filter(\.isFavorite)
        case .saved: result = result.filter(\.isSaved)
        }

        if let style = selectedStyle {
            result = result.filter { $0.styles.contains(style) }
        }
        if let mood = selectedMood {
            result = result.filter { $0.mood == mood }
        }
        if let occasion = selectedOccasion {
            result = result.filter { $0.occasion == occasion }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { image in
                image.title.lowercased().contains(query)
                    || image.description.lowercased().contains(query)
                    || image.tags.contains { $0.lowercased().contains(query) }
                    || (image.photographer?.lowercased().contains(query) ?? false)
                    || (image.location?.lowercased().contains(query) ?? false)
                    || (image.occasion?.rawValue.lowercased().contains(query) ?? false)
                    || image.mood.rawValue.lowercased().contains(query)
            }
        }

        return result
    }

    private func sortImages(_ source: [MuseImage]) -> [MuseImage] {
        switch feedSort {
        case .dateNewest:
            return source.sorted { $0.createdAt > $1.createdAt }
        case .dateOldest:
            return source.sorted { $0.createdAt < $1.createdAt }
        case .titleAZ:
            return source.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA:
            return source.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .styleCount:
            return source.sorted {
                if $0.styles.count == $1.styles.count {
                    return $0.createdAt > $1.createdAt
                }
                return $0.styles.count > $1.styles.count
            }
        }
    }

    private func updateInsights() {
        insights = []
        for style in StyleCategory.allCases {
            let styleImages = images.filter { $0.styles.contains(style) }
            guard styleImages.count >= 3 else { continue }

            let commonMood = Dictionary(grouping: styleImages, by: \.mood)
                .max { $0.value.count < $1.value.count }?.key

            var description: String
            var tips: [String]
            var colorPalette: [String]

            switch style {
            case .casual:
                description = "Everyday style that blends comfort and natural ease."
                tips = ["Mix basic pieces", "Add accessories", "Use neutral colors"]
                colorPalette = ["#8B9DC3", "#C5D0E6", "#F5F5F5"]
            case .elegant:
                description = "Refined style that highlights femininity and sophistication."
                tips = ["Choose quality fabrics", "Keep accessories minimal", "Silhouette comes first"]
                colorPalette = ["#1A1A1A", "#D4AF37", "#FFFFFF"]
            case .streetwear:
                description = "Urban youth style combining comfort and self-expression."
                tips = ["Oversized fits work well", "Sneakers anchor the look", "Layering adds depth"]
                colorPalette = ["#2D2D2D", "#C41E3A", "#4169E1"]
            case .boho:
                description = "Free-spirited looks with flowing textures and earthy tones."
                tips = ["Layer jewelry", "Mix patterns carefully", "Embrace natural fabrics"]
                colorPalette = ["#C4A484", "#8B7355", "#F5E6D3"]
            case .minimal:
                description = "Clean lines and restrained palettes for a polished feel."
                tips = ["Stick to a tight palette", "Focus on fit", "One statement piece is enough"]
                colorPalette = ["#FFFFFF", "#E0E0E0", "#333333"]
            case .glam:
                description = "Bold shine and statement pieces for standout moments."
                tips = ["Balance sparkle with neutrals", "Highlight one feature", "Evening-ready textures"]
                colorPalette = ["#FFD700", "#1A1A1A", "#C0C0C0"]
            case .sporty:
                description = "Active-inspired outfits with dynamic, functional energy."
                tips = ["Pair athleisure with structure", "Bold sneakers", "Monochrome sets"]
                colorPalette = ["#FF4500", "#2D2D2D", "#FFFFFF"]
            case .vintage:
                description = "Retro silhouettes and nostalgic details from past decades."
                tips = ["Source classic cuts", "Mix eras thoughtfully", "Patina adds character"]
                colorPalette = ["#8B4513", "#D2691E", "#F5DEB3"]
            case .ethereal:
                description = "Soft, dreamy aesthetics with light fabrics and gentle hues."
                tips = ["Sheer layers", "Pastel gradients", "Delicate accessories"]
                colorPalette = ["#E6E6FA", "#FFB6C1", "#F0F8FF"]
            case .edgy:
                description = "Sharp contrasts and daring details that push boundaries."
                tips = ["Leather accents", "Dark base palette", "Unexpected proportions"]
                colorPalette = ["#1A1A1A", "#8B0000", "#4A4A4A"]
            }

            if let mood = commonMood {
                description += " Often associated with a \(mood.rawValue.lowercased()) mood."
            }

            insights.append(StyleInsight(
                id: UUID(),
                style: style,
                description: description,
                tips: tips,
                colorPalette: colorPalette
            ))
        }
        saveToUserDefaults()
    }

    private let demoVersionKey = "museboard_demo_version"
    private let currentDemoVersion = 2

    private let imagesKey = "museboard_images"
    private let boardsKey = "museboard_boards"
    private let collectionsKey = "museboard_collections"
    private let insightsKey = "museboard_insights"
    private let notesKey = "museboard_notes"
    private let tipsKey = "museboard_checked_tips"
    private let goalsKey = "museboard_style_goals"

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(images) {
            UserDefaults.standard.set(encoded, forKey: imagesKey)
        }
        if let encoded = try? JSONEncoder().encode(boards) {
            UserDefaults.standard.set(encoded, forKey: boardsKey)
        }
        if let encoded = try? JSONEncoder().encode(collections) {
            UserDefaults.standard.set(encoded, forKey: collectionsKey)
        }
        if let encoded = try? JSONEncoder().encode(insights) {
            UserDefaults.standard.set(encoded, forKey: insightsKey)
        }
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
        UserDefaults.standard.set(Array(checkedTipKeys), forKey: tipsKey)
        let goalPayload = styleGoalTargets.map { ["style": $0.key.rawValue, "target": $0.value] }
        if let encoded = try? JSONSerialization.data(withJSONObject: goalPayload) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: imagesKey),
           let decoded = try? JSONDecoder().decode([MuseImage].self, from: data) {
            images = decoded
        }
        if let data = UserDefaults.standard.data(forKey: boardsKey),
           let decoded = try? JSONDecoder().decode([Board].self, from: data) {
            boards = decoded
        }
        if let data = UserDefaults.standard.data(forKey: collectionsKey),
           let decoded = try? JSONDecoder().decode([Collection].self, from: data) {
            collections = decoded
        }
        if let data = UserDefaults.standard.data(forKey: insightsKey),
           let decoded = try? JSONDecoder().decode([StyleInsight].self, from: data) {
            insights = decoded
        }
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([PersonalNote].self, from: data) {
            notes = decoded
        }
        if let tips = UserDefaults.standard.array(forKey: tipsKey) as? [String] {
            checkedTipKeys = Set(tips)
        }
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            var goals: [StyleCategory: Int] = [:]
            for item in array {
                if let raw = item["style"] as? String,
                   let style = StyleCategory(rawValue: raw),
                   let target = item["target"] as? Int {
                    goals[style] = target
                }
            }
            styleGoalTargets = goals
        }

        let savedDemoVersion = UserDefaults.standard.integer(forKey: demoVersionKey)
        if images.isEmpty || (savedDemoVersion < currentDemoVersion && images.count <= 2) {
            loadDemoData()
            UserDefaults.standard.set(currentDemoVersion, forKey: demoVersionKey)
        } else {
            updateInsights()
        }
    }

    private func loadDemoData() {
        let demo = MuseDemoContent.make()
        images = demo.images
        boards = demo.boards
        collections = demo.collections
        notes = demo.notes
        styleGoalTargets = demo.styleGoalTargets
        updateInsights()
        saveToUserDefaults()
    }

    /// Reorders IDs for `List.onMove` without importing SwiftUI.
    private func moveIds(_ ids: inout [UUID], fromOffsets source: IndexSet, toOffset destination: Int) {
        guard !source.isEmpty else { return }
        let moving = source.sorted().map { ids[$0] }
        var remaining = ids.enumerated().filter { !source.contains($0.offset) }.map(\.element)
        let insertIndex = destination - source.filter { $0 < destination }.count
        remaining.insert(contentsOf: moving, at: min(max(insertIndex, 0), remaining.count))
        ids = remaining
    }
}
