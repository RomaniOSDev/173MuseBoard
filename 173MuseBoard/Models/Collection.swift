import Foundation

struct Collection: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var coverImageName: String?
    var imageIds: [UUID]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        coverImageName: String? = nil,
        imageIds: [UUID],
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.coverImageName = coverImageName
        self.imageIds = imageIds
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, coverImageName, imageIds, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        coverImageName = try container.decodeIfPresent(String.self, forKey: .coverImageName)
        imageIds = try container.decode([UUID].self, forKey: .imageIds)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}
