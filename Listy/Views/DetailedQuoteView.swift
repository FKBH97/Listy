import SwiftUI

struct DetailedQuoteView: View {
    @ObservedObject var quoteItem: QuoteItem

    var body: some View {
        Form {
            Section(header: Text("Quote")) {
                Text(quoteItem.text ?? "No text available")
            }
            Section(header: Text("Author")) {
                Text(quoteItem.author ?? "Unknown author")
            }
            Section(header: Text("Location")) {
                Text(quoteItem.location ?? "Unknown location")
            }
            Section(header: Text("Context")) {
                Text(quoteItem.context ?? "No context provided")
            }
        }
        .navigationTitle("Quote Details")
    }
}
