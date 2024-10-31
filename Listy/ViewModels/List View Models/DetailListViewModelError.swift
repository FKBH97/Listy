import Foundation

enum DetailListViewModelError: LocalizedError, Identifiable {
    case fetchFailed(String)
    case saveFailed(String)
    case deleteFailed(String)
    case unknown(String)

    var id: String {
        localizedDescription
    }

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let reason):
            return "Failed to fetch items: \(reason)"
        case .saveFailed(let reason):
            return "Failed to save item: \(reason)"
        case .deleteFailed(let reason):
            return "Failed to delete item: \(reason)"
        case .unknown(let reason):
            return "Unknown error occurred: \(reason)"
        }
    }
}
