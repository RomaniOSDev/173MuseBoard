import Foundation

struct MuseImage: Identifiable, Codable, Equatable {
    let id: UUID
    var imageNames: [String]
    var title: String
    var description: String
    var styles: [StyleCategory]
    var mood: Mood
    var occasion: Occasion?
    var tags: [String]
    var photographer: String?
    var location: String?
    var dateTaken: Date?
    var isFavorite: Bool
    var isSaved: Bool
    let createdAt: Date
    var updatedAt: Date?

    var primaryImageName: String {
        imageNames.first ?? "girl1"
    }

    enum CodingKeys: String, CodingKey {
        case id, imageNames, imageName, title, description, styles, mood, occasion, tags
        case photographer, location, dateTaken, isFavorite, isSaved, createdAt, updatedAt
    }

    init(
        id: UUID = UUID(),
        imageNames: [String],
        title: String,
        description: String,
        styles: [StyleCategory],
        mood: Mood,
        occasion: Occasion? = nil,
        tags: [String],
        photographer: String? = nil,
        location: String? = nil,
        dateTaken: Date? = nil,
        isFavorite: Bool,
        isSaved: Bool,
        createdAt: Date,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.imageNames = imageNames.isEmpty ? ["girl1"] : imageNames
        self.title = title
        self.description = description
        self.styles = styles
        self.mood = mood
        self.occasion = occasion
        self.tags = tags
        self.photographer = photographer
        self.location = location
        self.dateTaken = dateTaken
        self.isFavorite = isFavorite
        self.isSaved = isSaved
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        if let names = try container.decodeIfPresent([String].self, forKey: .imageNames), !names.isEmpty {
            imageNames = names
        } else if let single = try container.decodeIfPresent(String.self, forKey: .imageName) {
            imageNames = [single]
        } else {
            imageNames = ["girl1"]
        }
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        styles = try container.decode([StyleCategory].self, forKey: .styles)
        mood = try container.decode(Mood.self, forKey: .mood)
        occasion = try container.decodeIfPresent(Occasion.self, forKey: .occasion)
        tags = try container.decode([String].self, forKey: .tags)
        photographer = try container.decodeIfPresent(String.self, forKey: .photographer)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        dateTaken = try container.decodeIfPresent(Date.self, forKey: .dateTaken)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        isSaved = try container.decode(Bool.self, forKey: .isSaved)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(imageNames, forKey: .imageNames)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(styles, forKey: .styles)
        try container.encode(mood, forKey: .mood)
        try container.encodeIfPresent(occasion, forKey: .occasion)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(photographer, forKey: .photographer)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(dateTaken, forKey: .dateTaken)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(isSaved, forKey: .isSaved)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
}
