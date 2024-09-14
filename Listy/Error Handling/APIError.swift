enum APIError: Error, Identifiable {
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    
    // Conforming to Identifiable by providing a unique `id` for each error
    var id: String {
        switch self {
        case .networkError(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Invalid Response"
        case .decodingError(let error):
            return error.localizedDescription
        }
    }
}
