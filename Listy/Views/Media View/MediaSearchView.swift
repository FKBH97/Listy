import SwiftUI

struct MediaSearchView: View {
    @StateObject private var viewModel = MediaSearchViewModel()
    @Environment(\.presentationMode) var presentationMode
    var onSelect: (MediaSearchResult) -> Void

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a movie or TV show", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if viewModel.isSearching {
                    ProgressView("Searching...")
                } else if viewModel.searchResults.isEmpty {
                    Text("No results found")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.searchResults) { result in
                        Button(action: {
                            onSelect(result)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            MediaSearchResultRow(result: result)
                        }
                    }
                }
            }
            .navigationTitle("Search Media")
            .alert(item: $viewModel.error) { error in
                Alert(title: Text("Error"), message: Text(error.localizedDescription))
            }
        }
    }
}
