import SwiftUI

struct MediaDetailView: View {
    let mediaItem: MediaListItem
    @StateObject private var viewModel = MediaDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let posterURL = viewModel.mediaDetails?.fullPosterURL {
                    AsyncImage(url: posterURL) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 300)
                }

                Text(viewModel.mediaDetails?.displayTitle ?? "Unknown Title")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Type: \(viewModel.mediaDetails?.mediaType?.capitalized ?? "Unknown")")
                    .font(.subheadline)

                if let releaseDate = viewModel.mediaDetails?.releaseDate {
                    Text("Release Date: \(releaseDate)")
                        .font(.subheadline)
                }

                if let voteAverage = viewModel.mediaDetails?.voteAverage {
                    Text("Rating: \(voteAverage, specifier: "%.1f")/10")
                        .font(.subheadline)
                }

                if let overview = viewModel.mediaDetails?.overview {
                    Text("Overview")
                        .font(.headline)
                    Text(overview)
                        .font(.body)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchDetails(tmdbId: mediaItem.tmdbId, mediaType: mediaItem.mediaType ?? "")
        }
        .alert(item: $viewModel.error) { error in
            Alert(title: Text("Error"), message: Text(error.errorDescription ?? "Unknown error"))
        }
        .overlay(loadingOverlay)
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            ProgressView("Loading...")
                .padding()
                .background(Color.secondary.colorInvert())
                .cornerRadius(10)
                .shadow(radius: 10)
        }
    }
}
