import Foundation

struct PersonalNote: Identifiable, Codable, Equatable {
    let id: UUID
    let imageId: UUID
    var content: String
    let createdAt: Date
}
