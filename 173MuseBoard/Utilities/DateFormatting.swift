import Foundation

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy"
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: date)
}
