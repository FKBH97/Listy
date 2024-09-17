import Foundation

struct Formatters {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    static func formatDate(_ date: String?) -> String {
        guard let dateString = date, let dateObj = ISO8601DateFormatter().date(from: dateString) else {
            return "N/A"
        }
        return dateFormatter.string(from: dateObj)
    }

    static func formatRating(_ rating: Double?) -> String {
        guard let rating = rating else { return "N/A" }
        return numberFormatter.string(from: NSNumber(value: rating)) ?? "N/A"
    }
}
