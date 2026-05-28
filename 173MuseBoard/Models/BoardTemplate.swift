import Foundation

struct BoardTemplate: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let coverImageName: String
    let isPublic: Bool

    static let presets: [BoardTemplate] = [
        BoardTemplate(
            name: "Evening",
            description: "Evening and night-out inspiration",
            coverImageName: "girl2",
            isPublic: true
        ),
        BoardTemplate(
            name: "Casual Week",
            description: "Relaxed everyday looks for the week",
            coverImageName: "girl1",
            isPublic: true
        ),
        BoardTemplate(
            name: "Travel Capsule",
            description: "Packable outfits for trips",
            coverImageName: "girl5",
            isPublic: false
        )
    ]
}
