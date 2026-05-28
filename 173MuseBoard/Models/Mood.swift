import Foundation

enum Mood: String, CaseIterable, Codable {
    case happy = "Joy"
    case dreamy = "Dreamy"
    case confident = "Confident"
    case mysterious = "Mysterious"
    case playful = "Playful"
    case serene = "Serene"
    case bold = "Bold"

    var icon: String {
        switch self {
        case .happy: return "face.smiling.fill"
        case .dreamy: return "cloud.fill"
        case .confident: return "star.fill"
        case .mysterious: return "eye.fill"
        case .playful: return "heart.fill"
        case .serene: return "leaf.fill"
        case .bold: return "bolt.fill"
        }
    }
}
