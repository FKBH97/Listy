import Foundation

class TMDbAPIService {
    static let shared = TMDbAPIService()
    private init() {}

    func searchMedia(query: String, completion: @escaping (Result<[MediaSearchResult], APIError>) -> Void) {
        let urlString = "\(TMDbAPIConfig.baseURL)/search/multi?api_key=\(TMDbAPIConfig.apiKey)&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidResponse))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let searchResponse = try JSONDecoder().decode(MediaSearchResponse.self, from: data)
                completion(.success(searchResponse.results))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
