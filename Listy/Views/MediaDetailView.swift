import SwiftUI

struct MediaDetailView: View {
    @ObservedObject var mediaItem: MediaListItem

    var body: some View {
        VStack {
            Text("Media: \(mediaItem.text ?? "")")
            Text("Type: \(mediaItem.mediaType ?? "Unknown")")
            Text("Source: \(mediaItem.source ?? "Unknown")")
            Text("Rating: \(mediaItem.mediaRating, specifier: "%.1f")/5")
        }
        .navigationTitle("Media Details")
    }
}
