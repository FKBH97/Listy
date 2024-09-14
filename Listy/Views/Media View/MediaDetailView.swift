
import SwiftUI

struct MediaDetailView: View {
    @ObservedObject var mediaItem: MediaListItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let posterURL = mediaItem.posterURL, let url = URL(string: posterURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 300)
                }
                
                Text(mediaItem.text ?? "")
                    .font(.title)
                
                Text("Type: \(mediaItem.mediaType ?? "Unknown")")
                
                if let releaseDate = mediaItem.releaseDate {
                    Text("Release Date: \(releaseDate, formatter: dateFormatter)")
                }
                
                Text("Rating: \(mediaItem.mediaRating, specifier: "%.1f")/10")
                
                if let overview = mediaItem.overview {
                    Text("Overview").font(.headline)
                    Text(overview)
                }
            }
            .padding()
        }
        .navigationTitle("Media Details")
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
