import Foundation
import Combine

class MediaSearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [MediaSearchResult] = []
    @Published var isSearching: Bool = false
    @Published var error: APIError?

    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchMedia(query: query)
            }
            .store(in: &cancellables)
    }

    func searchMedia(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        TMDbAPIService.shared.searchMedia(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSearching = false
                switch result {
                case .success(let results):
                    self?.searchResults = results
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}
