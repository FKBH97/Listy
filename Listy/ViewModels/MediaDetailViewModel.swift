import Foundation
import Combine

class MediaDetailViewModel: ObservableObject {
    @Published var mediaDetails: MediaSearchResult?
    @Published var isLoading = false
    @Published var error: IdentifiableError?

    func fetchDetails(tmdbId: Int64, mediaType: String) {
        guard tmdbId != 0 else {
            print("Invalid tmdbId: \(tmdbId)")
            self.error = IdentifiableError(APIError.invalidData)
            return
        }

        isLoading = true
        print("Fetching details for tmdbId: \(tmdbId), mediaType: \(mediaType)")

        TMDbAPIService.shared.getMediaDetailsWithRetry(id: Int(tmdbId), mediaType: mediaType) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let details):
                    print("Successfully fetched details for tmdbId: \(tmdbId)")
                    self?.mediaDetails = details
                case .failure(let apiError):
                    print("Failed to fetch details: \(apiError.localizedDescription)")
                    self?.error = IdentifiableError(apiError)
                }
            }
        }
    }
}
