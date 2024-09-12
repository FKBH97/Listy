import SwiftUI

struct DetailListView: View {
    @StateObject private var viewModel: DetailListViewModel
    @State private var showingAddItem = false

    init(list: CustomList) {
        _viewModel = StateObject(wrappedValue: DetailListViewModel(list: list))
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                List {
                    ForEach(viewModel.items, id: \.self) { item in
                        listItemView(for: item)
                    }
                    .onDelete { offsets in
                        viewModel.deleteItems(at: offsets)
                    }
                    .onMove { source, destination in
                        viewModel.moveItems(from: source, to: destination)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingAddItem = true }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddListItemView(list: viewModel.list) { text, author, location, context in
                if viewModel.list.wrappedCategory == ListCategory.quotes.rawValue {
                    viewModel.addQuoteItem(text: text, author: author, location: location, context: context)
                } else {
                    viewModel.addItem(text: text)
                }
            }
        }
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle(viewModel.list.wrappedName)
    }

    @ViewBuilder
    private func listItemView(for item: ListItem) -> some View {
        switch item {
        case let quoteItem as QuoteItem:
            NavigationLink(destination: DetailedQuoteView(quoteItem: quoteItem)) {
                Text("\"\(quoteItem.text ?? "")\"") // Adds quotation marks
            }
        case let mediaItem as MediaListItem:
            NavigationLink(destination: MediaDetailView(mediaItem: mediaItem)) {
                Text(mediaItem.text ?? "Unnamed Media")
            }
        case let taskItem as TaskItem:
            NavigationLink(destination: TaskDetailView(taskItem: taskItem)) {
                Text(taskItem.text ?? "Unnamed Task")
            }
        default:
            Text(item.text ?? "Unnamed Item")
        }
    }
}
