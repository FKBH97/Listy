import Foundation

enum AppError: LocalizedError, Identifiable {
    case fetchError(String)
    case saveError(String)
    case deleteError(String)
    case unknownError(String)
    
    var id: String { localizedDescription }
    
    var errorDescription: String? {
        switch self {
        case .fetchError(let message): return "Fetch Error: \(message)"
        case .saveError(let message): return "Save Error: \(message)"
        case .deleteError(let message): return "Delete Error: \(message)"
        case .unknownError(let message): return "Unknown Error: \(message)"
        }
    }
}
