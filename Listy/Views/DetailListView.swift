import SwiftUI
import CoreData

struct DetailListView: View {
    @ObservedObject var list: CustomList
    @StateObject private var viewModel: DetailListViewModel
    @State private var showingAddItem = false
    @State private var showingError = false
    @State private var editingItem: ListItem?

    init(list: CustomList) {
        self.list = list
        _viewModel = StateObject(wrappedValue: DetailListViewModel(list: list))
    }

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.items, id: \.self) { item in
                    if list.wrappedCategory == .tasks {
                        Button(action: {
                            toggleItemCheck(item)
                        }) {
                            HStack {
                                Image(systemName: item.isChecked ? "checkmark.square" : "square")
                                Text(item.wrappedText)
                            }
                        }
                    } else {
                        NavigationLink(destination: EditItemView(item: item) { newText in
                            updateItemText(item, newText: newText)
                        }) {
                            Text(item.wrappedText)
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

    private func toggleItemCheck(_ item: ListItem) {
        do {
            try viewModel.toggleItemCheck(item)
        } catch {
            showError(error)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            do {
                try viewModel.deleteItems(at: offsets)
            } catch {
                showError(error)
            }
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        do {
            try viewModel.moveItems(from: source, to: destination)
        } catch {
            showError(error)
        }
    }

    private func addItem(_ text: String) {
        do {
            try viewModel.addItem(text)
        } catch {
            showError(error)
        }
    }

    private func updateItemText(_ item: ListItem, newText: String) {
        do {
            try viewModel.updateItemText(item, newText: newText)
        } catch {
            showError(error)
        }
    }

    private func showError(_ error: Error) {
        viewModel.error = error as? DetailListViewModelError ?? .unknown(error.localizedDescription)
        showingError = true
    }
}

struct DetailListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleList = CustomList(context: context)
        sampleList.name = "Sample List"
        return DetailListView(list: sampleList)
    }
}
