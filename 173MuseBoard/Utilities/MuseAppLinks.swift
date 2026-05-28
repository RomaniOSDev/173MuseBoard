import UIKit

enum MuseAppLinks {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://www.termsfeed.com/live/acfdeaa6-fa80-478c-a53b-42505c090fbb"
        case .termsOfUse:
            return "https://www.termsfeed.com/live/7b3655c8-bb1e-48c3-82c3-e1d34a5ee9fe"
        }
    }

    func open() {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
