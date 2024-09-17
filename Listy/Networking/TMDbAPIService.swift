import Foundation

class TMDbAPIService {
    static let shared = TMDbAPIService()

    // Search media based on query
    func searchMedia(query: String, completion: @escaping (Result<[MediaSearchResult], IdentifiableError>) -> Void) {
        let accessToken = TMDbAPIConfig.shared.apiAccessToken
        let urlString = "\(TMDbAPIConfig.baseURL)/search/multi?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(IdentifiableError(APIError.invalidURL)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(IdentifiableError(APIError.networkError(error))))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(IdentifiableError(APIError.invalidResponse)))
                return
            }

            guard let data = data else {
                completion(.failure(IdentifiableError(APIError.noData)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(MediaSearchResponse.self, from: data)
                print("Successfully decoded search response")
                completion(.success(decodedResponse.results))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(IdentifiableError(APIError.decodingError)))
            }
        }.resume()
    }

    // Fetch media details based on the media ID and type
    func getMediaDetails(id: Int, mediaType: String, completion: @escaping (Result<MediaSearchResult, IdentifiableError>) -> Void) {
        let accessToken = TMDbAPIConfig.shared.apiAccessToken
        let urlString = "\(TMDbAPIConfig.baseURL)/\(mediaType)/\(id)"

        guard let url = URL(string: urlString) else {
            completion(.failure(IdentifiableError(APIError.invalidURL)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(IdentifiableError(APIError.networkError(error))))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(IdentifiableError(APIError.invalidResponse)))
                return
            }

            guard let data = data else {
                completion(.failure(IdentifiableError(APIError.noData)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(MediaSearchResult.self, from: data)
                print("Successfully fetched media details")
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(IdentifiableError(APIError.decodingError)))
            }
        }.resume()
    }

    // Retry Logic Implementation
    func getMediaDetailsWithRetry(id: Int, mediaType: String, retries: Int = 3, completion: @escaping (Result<MediaSearchResult, IdentifiableError>) -> Void) {
        getMediaDetails(id: id, mediaType: mediaType) { result in
            switch result {
            case .success:
                completion(result)
            case .failure(let error):
                if retries > 0 {
                    print("Retrying API call. Attempts left: \(retries - 1)")
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                        self.getMediaDetailsWithRetry(id: id, mediaType: mediaType, retries: retries - 1, completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}
