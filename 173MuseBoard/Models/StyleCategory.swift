import Foundation

enum StyleCategory: String, CaseIterable, Codable {
    case casual = "Casual"
    case elegant = "Elegant"
    case streetwear = "Streetwear"
    case boho = "Boho"
    case minimal = "Minimal"
    case glam = "Glam"
    case sporty = "Sporty"
    case vintage = "Vintage"
    case ethereal = "Ethereal"
    case edgy = "Edgy"

    var icon: String {
        switch self {
        case .casual: return "tshirt.fill"
        case .elegant: return "crown.fill"
        case .streetwear: return "shoe.fill"
        case .boho: return "leaf.fill"
        case .minimal: return "circle.fill"
        case .glam: return "star.fill"
        case .sporty: return "bolt.fill"
        case .vintage: return "clock.fill"
        case .ethereal: return "sparkles"
        case .edgy: return "flame.fill"
        }
    }
}
