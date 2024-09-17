import SwiftUI

struct MediaSearchResultRow: View {
    let result: MediaSearchResult

    var body: some View {
        HStack {
            // Safely unwrap the URL from result.fullPosterPath
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

                // Safely unwrap result.mediaType and capitalize it, provide default if nil
                Text(result.mediaType?.capitalized ?? "Unknown")
                    .font(.caption)
            }
        }
    }
}
