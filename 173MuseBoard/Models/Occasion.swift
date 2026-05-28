import Foundation

enum Occasion: String, CaseIterable, Codable {
    case work = "Work"
    case date = "Date"
    case travel = "Travel"
    case party = "Party"
    case weekend = "Weekend"
    case everyday = "Everyday"

    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .date: return "heart.circle.fill"
        case .travel: return "airplane"
        case .party: return "sparkles"
        case .weekend: return "sun.max.fill"
        case .everyday: return "calendar"
        }
    }
}
