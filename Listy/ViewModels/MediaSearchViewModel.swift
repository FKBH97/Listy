import SwiftUI
import Combine
import Foundation

class MediaSearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [MediaSearchResult] = []
    @Published var isSearching: Bool = false
    @Published var error: IdentifiableError?  // Change from APIError to IdentifiableError

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                print("Search query updated: \(query)")
                self?.searchMedia(query: query)
            }
            .store(in: &cancellables)
    }

    func searchMedia(query: String) {
        guard !query.isEmpty else {
            print("Empty search query")
            searchResults = []
            return
        }

        isSearching = true
        print("Searching media for query: \(query)")
        
        TMDbAPIService.shared.searchMedia(query: query) { [weak self] (result: Result<[MediaSearchResult], IdentifiableError>) in
            DispatchQueue.main.async {
                self?.isSearching = false
                switch result {
                case .success(let results):
                    print("SearchMedia Success: Found \(results.count) results")
                    self?.searchResults = results
                case .failure(let error):
                    print("SearchMedia Error: \(error.localizedDescription)")
                    self?.error = error
                }
            }
        }
    }
}
