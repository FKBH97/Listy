import Foundation

enum AppError: LocalizedError, Identifiable {
    case validationError(String)
    case saveError(String)
    case fetchError(String)
    
    var id: String { localizedDescription }
    
    var errorDescription: String? {
        switch self {
        case .validationError(let message): return message
        case .saveError(let message): return "Save failed: \(message)"
        case .fetchError(let message): return "Fetch failed: \(message)"
        }
    }
}
