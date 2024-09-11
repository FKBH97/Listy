import SwiftUI
import CoreData

struct DetailListView: View {
    @ObservedObject var list: CustomList
    @StateObject private var viewModel: DetailListViewModel
    @State private var showingAddItem = false
    @State private var showingError = false

    init(list: CustomList) {
        self.list = list
        _viewModel = StateObject(wrappedValue: DetailListViewModel(list: list))
    }

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.items, id: \.self) { item in
                    if let quoteItem = item as? QuoteItem {
                        NavigationLink(destination: DetailedQuoteView(quoteItem: quoteItem)) {
                            Text("“\(quoteItem.text ?? "")”")
                        }
                    } else if let mediaItem = item as? MediaListItem {
                        NavigationLink(destination: MediaDetailView(mediaItem: mediaItem)) {
                            Text(mediaItem.text ?? "No title")
                        }
                    } else if let taskItem = item as? TaskItem {
                        NavigationLink(destination: TaskDetailView(taskItem: taskItem)) {
                            Text(taskItem.text ?? "No task name")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            .navigationTitle(list.wrappedName)
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
                AddListItemView(list: list) { itemText in
                    addItem(itemText)
                }
            }
            .alert(isPresented: $showingError) {
                Alert(title: Text("Error"), message: Text(viewModel.error?.localizedDescription ?? "An unknown error occurred"), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                viewModel.fetchItems()
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            viewModel.deleteItems(at: offsets)
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        viewModel.moveItems(from: source, to: destination)
    }

    private func addItem(_ text: String) {
        viewModel.addItem(text: text)
    }

    private func showError(_ error: Error) {
        viewModel.error = error as? DetailListViewModelError ?? .unknown(error.localizedDescription)
        showingError = true
    }
}

