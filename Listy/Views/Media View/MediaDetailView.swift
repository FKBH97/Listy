import SwiftUI

struct MediaDetailView: View {
    @ObservedObject var mediaItem: MediaListItem
    @State private var apiDetails: MediaSearchResult?
    @State private var isLoading = false
    @State private var error: IdentifiableError?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Poster image
                if let posterURL = mediaItem.posterURL, let url = URL(string: posterURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 300)
                }

                Text(mediaItem.text ?? "Unknown Title")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Type: \(mediaItem.mediaType ?? "Unknown")")
                    .font(.subheadline)

                if let releaseDate = mediaItem.releaseDate {
                    Text("Release Date: \(releaseDate, formatter: dateFormatter)")
                        .font(.subheadline)
                }

                // Handle NaN values and provide default rating
                Text("Rating: \(mediaItem.mediaRating.isNaN ? "N/A" : "\(mediaItem.mediaRating, specifier: "%.1f")")/10")
                    .font(.subheadline)

                if let overview = mediaItem.overview {
                    Text("Overview")
                        .font(.headline)
                    Text(overview)
                        .font(.body)
                }

                if let voteAverage = apiDetails?.voteAverage, !voteAverage.isNaN {
                    Text("Vote Average: \(voteAverage, specifier: "%.1f")")
                } else {
                    Text("Vote Average: N/A")
                }
            }
            .padding()
        }
        .frame(minHeight: 0, maxHeight: .infinity)
        .navigationTitle("Media Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("onAppear called - View has appeared.")
            DispatchQueue.main.async {
                print("Calling fetchAPIDetails after a delay.")
                fetchAPIDetails()
            }
        }
        .alert(item: $error) { error in
            Alert(title: Text("Error"), message: Text(error.errorDescription ?? "An unknown error occurred."))
        }
        .overlay(loadingOverlay)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            ProgressView("Loading...")
                .padding()
                .background(Color.secondary.colorInvert())
                .cornerRadius(10)
                .shadow(radius: 10)
        } else {
            EmptyView()
        }
    }

    private func fetchAPIDetails() {
        guard mediaItem.tmdbId != 0 else {
            print("fetchAPIDetails: Invalid tmdbId - \(mediaItem.tmdbId)")
            self.error = IdentifiableError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid tmdbId"]))
            return
        }

        isLoading = true
        print("fetchAPIDetails: Fetching details for ID: \(mediaItem.tmdbId), Type: \(mediaItem.mediaType ?? "Unknown")")
        
        TMDbAPIService.shared.getMediaDetails(id: Int(mediaItem.tmdbId), mediaType: mediaItem.mediaType ?? "") { result in
            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let details):
                    print("fetchAPIDetails: Successfully fetched details.")
                    self.apiDetails = details
                case .failure(let apiError):
                    print("fetchAPIDetails: Failed with error: \(apiError.localizedDescription)")
                    self.error = IdentifiableError(apiError)
                }
            }
        }
    }
}
