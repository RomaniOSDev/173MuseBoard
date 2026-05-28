import Foundation

struct Board: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var coverImageName: String
    var imageIds: [UUID]
    var isPublic: Bool
    let createdAt: Date
}
