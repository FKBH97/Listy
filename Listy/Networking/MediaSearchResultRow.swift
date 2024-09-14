import SwiftUI

struct MediaSearchResultRow: View {
    let result: MediaSearchResult

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: result.fullPosterPath ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 75)

            VStack(alignment: .leading) {
                Text(result.displayTitle)
                    .font(.headline)
                Text(result.displayDate)
                    .font(.subheadline)
                Text(result.mediaType.capitalized)
                    .font(.caption)
            }
        }
    }
}
