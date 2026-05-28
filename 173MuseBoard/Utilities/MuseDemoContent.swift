import Foundation

/// Pre-installed library shown on first launch (when UserDefaults is empty).
enum MuseDemoContent {
    struct Bundle {
        let images: [MuseImage]
        let boards: [Board]
        let collections: [Collection]
        let notes: [PersonalNote]
        let styleGoalTargets: [StyleCategory: Int]
    }

    static func make() -> Bundle {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: today) ?? today
        }

        let items: [(MuseImage, Int)] = [
            (
                MuseImage(
                    imageNames: ["presetFeatured1"],
                    title: "Sunlit Street Style",
                    description: "Linen layers and clean sneakers for a warm city afternoon.",
                    styles: [.casual, .minimal],
                    mood: .happy,
                    occasion: .weekend,
                    tags: ["summer", "linen", "street"],
                    photographer: "Muse Editorial",
                    location: "Lisbon",
                    dateTaken: daysAgo(1),
                    isFavorite: true,
                    isSaved: true,
                    createdAt: daysAgo(0)
                ),
                0
            ),
            (
                MuseImage(
                    imageNames: ["presetFeatured2"],
                    title: "Rose Gold Evening",
                    description: "Slip dress with delicate gold accents — date-night ready.",
                    styles: [.elegant, .glam],
                    mood: .confident,
                    occasion: .date,
                    tags: ["evening", "gold", "dress"],
                    photographer: "Studio M",
                    location: "Paris",
                    dateTaken: daysAgo(3),
                    isFavorite: true,
                    isSaved: false,
                    createdAt: daysAgo(1)
                ),
                1
            ),
            (
                MuseImage(
                    imageNames: ["presetFeatured3"],
                    title: "Golden Hour Boho",
                    description: "Flowing textures and earthy tones by the coast.",
                    styles: [.boho, .ethereal],
                    mood: .dreamy,
                    occasion: .travel,
                    tags: ["boho", "beach", "hat"],
                    photographer: "Coastal Co.",
                    location: "Santorini",
                    dateTaken: daysAgo(5),
                    isFavorite: false,
                    isSaved: true,
                    createdAt: daysAgo(2)
                ),
                2
            ),
            (
                MuseImage(
                    imageNames: ["girl4"],
                    title: "Urban Layers",
                    description: "Oversized jacket and monochrome base for streetwear energy.",
                    styles: [.streetwear, .edgy],
                    mood: .bold,
                    occasion: .everyday,
                    tags: ["layers", "urban", "monochrome"],
                    location: "Tokyo",
                    isFavorite: true,
                    isSaved: false,
                    createdAt: daysAgo(3)
                ),
                3
            ),
            (
                MuseImage(
                    imageNames: ["girl5"],
                    title: "Soft Minimal Office",
                    description: "Structured neutrals that still feel relaxed at work.",
                    styles: [.minimal, .casual, .boho],
                    mood: .serene,
                    occasion: .work,
                    tags: ["office", "neutral", "clean"],
                    location: "Copenhagen",
                    isFavorite: false,
                    isSaved: true,
                    createdAt: daysAgo(4)
                ),
                4
            ),
            (
                MuseImage(
                    imageNames: ["girl6"],
                    title: "Weekend Brunch Fit",
                    description: "Playful color pop with easy denim — effortless and bright.",
                    styles: [.casual, .sporty, .boho],
                    mood: .playful,
                    occasion: .weekend,
                    tags: ["brunch", "denim", "color"],
                    isFavorite: false,
                    isSaved: false,
                    createdAt: daysAgo(5)
                ),
                5
            ),
            (
                MuseImage(
                    imageNames: ["girl7"],
                    title: "Vintage Market Day",
                    description: "Retro silhouettes mixed with modern accessories.",
                    styles: [.vintage, .boho],
                    mood: .dreamy,
                    occasion: .weekend,
                    tags: ["vintage", "retro", "market"],
                    location: "London",
                    isFavorite: true,
                    isSaved: true,
                    createdAt: daysAgo(6)
                ),
                6
            ),
            (
                MuseImage(
                    imageNames: ["girl8"],
                    title: "Sporty City Morning",
                    description: "Athleisure set paired with a tailored coat for contrast.",
                    styles: [.sporty, .streetwear],
                    mood: .confident,
                    occasion: .everyday,
                    tags: ["athleisure", "morning", "run"],
                    isFavorite: false,
                    isSaved: false,
                    createdAt: daysAgo(6)
                ),
                7
            ),
            (
                MuseImage(
                    imageNames: ["girl9"],
                    title: "Party Sparkle",
                    description: "Statement shine balanced with a classic black base.",
                    styles: [.glam, .elegant],
                    mood: .bold,
                    occasion: .party,
                    tags: ["party", "sparkle", "night"],
                    location: "Miami",
                    isFavorite: true,
                    isSaved: false,
                    createdAt: daysAgo(7)
                ),
                8
            ),
            (
                MuseImage(
                    imageNames: ["girl10"],
                    title: "Mysterious Noir",
                    description: "Deep tones and sharp lines for an after-dark mood.",
                    styles: [.edgy, .elegant, .glam],
                    mood: .mysterious,
                    occasion: .date,
                    tags: ["noir", "dark", "contrast"],
                    isFavorite: false,
                    isSaved: true,
                    createdAt: daysAgo(7)
                ),
                9
            ),
            (
                MuseImage(
                    imageNames: ["girl11", "girl12"],
                    title: "Travel Capsule",
                    description: "Two-piece set that packs light and photographs beautifully.",
                    styles: [.minimal, .casual, .vintage],
                    mood: .serene,
                    occasion: .travel,
                    tags: ["capsule", "travel", "packing"],
                    location: "Barcelona",
                    isFavorite: true,
                    isSaved: true,
                    createdAt: daysAgo(2)
                ),
                10
            ),
            (
                MuseImage(
                    imageNames: ["girl13"],
                    title: "Ethereal Pastels",
                    description: "Sheer layers and soft lavender hues for a dreamy edit.",
                    styles: [.ethereal, .elegant],
                    mood: .dreamy,
                    occasion: .party,
                    tags: ["pastel", "sheer", "soft"],
                    isFavorite: false,
                    isSaved: false,
                    createdAt: daysAgo(4)
                ),
                11
            )
        ]

        let images = items.map(\.0)
        let byIndex = Dictionary(uniqueKeysWithValues: items.map { ($0.1, $0.0.id) })

        let boards: [Board] = [
            Board(
                id: UUID(),
                name: "Daily Inspiration",
                description: "Go-to looks for feed, home, and quick saves.",
                coverImageName: "presetFeatured1",
                imageIds: [0, 1, 2, 3, 5].compactMap { byIndex[$0] },
                isPublic: true,
                createdAt: daysAgo(10)
            ),
            Board(
                id: UUID(),
                name: "Evening & Events",
                description: "Dressier edits for dates, parties, and nights out.",
                coverImageName: "presetFeatured2",
                imageIds: [1, 8, 9].compactMap { byIndex[$0] },
                isPublic: false,
                createdAt: daysAgo(8)
            ),
            Board(
                id: UUID(),
                name: "Travel Mood",
                description: "Outfits that work on the road and in photos.",
                coverImageName: "presetFeatured3",
                imageIds: [2, 10, 11].compactMap { byIndex[$0] },
                isPublic: true,
                createdAt: daysAgo(6)
            )
        ]

        let collections: [Collection] = [
            Collection(
                name: "Summer Favorites",
                description: "Warm-weather ideas to revisit all season.",
                coverImageName: "presetFeatured1",
                imageIds: [0, 2, 5, 6].compactMap { byIndex[$0] },
                createdAt: daysAgo(9)
            ),
            Collection(
                name: "Saved for Later",
                description: "Looks to try on your next shopping trip.",
                coverImageName: "girl5",
                imageIds: [0, 4, 7, 10].compactMap { byIndex[$0] },
                createdAt: daysAgo(7)
            )
        ]

        let notes: [PersonalNote] = [
            PersonalNote(
                id: UUID(),
                imageId: byIndex[0]!,
                content: "Try with white sneakers and woven bag.",
                createdAt: daysAgo(0)
            ),
            PersonalNote(
                id: UUID(),
                imageId: byIndex[1]!,
                content: "Duplicate lip tone from palette for accessories.",
                createdAt: daysAgo(1)
            )
        ]

        let styleGoalTargets: [StyleCategory: Int] = [
            .casual: 8,
            .elegant: 6,
            .minimal: 5,
            .boho: 4
        ]

        return Bundle(
            images: images,
            boards: boards,
            collections: collections,
            notes: notes,
            styleGoalTargets: styleGoalTargets
        )
    }
}
