import Foundation

struct StyleInsight: Identifiable, Codable, Equatable {
    let id: UUID
    var style: StyleCategory
    var description: String
    var tips: [String]
    var colorPalette: [String]
}
