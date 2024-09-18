enum APIError: Error, Identifiable {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case invalidResponse
    case invalidData
    case unknownError(String)

    var id: String {
        switch self {
        case .invalidURL: return "invalidURL"
        case .noData: return "noData"
        case .decodingError: return "decodingError"
        case .networkError: return "networkError"
        case .unknownError(let message): return message
        case .invalidResponse: return "invalidResponse"
        case .invalidData: return "invalidData"
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingError:
            return "Failed to decode the response from the server."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        case .invalidResponse:
            return "The server responded with an invalid response. Please try again."
        case .invalidData:
            return "The data received from the server was invalid."
        }
    }
}
