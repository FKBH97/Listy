import SwiftUI
import CoreData

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var showingAddList = false

    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: MainViewModel(viewContext: viewContext))
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.lists, id: \.id) { list in
                    NavigationLink(destination: DetailListView(list: list)) {
                        Text(list.wrappedName)
                    }
                }
                .onDelete(perform: deleteLists)
                .onMove(perform: moveLists)
            }
            .navigationTitle("Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingAddList = true }) {
                        Label("Add List", systemImage: "plus")
                    }
                }
            }
            .alert(item: $viewModel.error) { error in
                Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingAddList) {
                AddListView { name, isChecklist, category in
                    viewModel.addList(name: name, isChecklist: isChecklist, category: category)
                }
            }
        }
    }

    private func deleteLists(offsets: IndexSet) {
        withAnimation {
            viewModel.deleteLists(at: offsets)
        }
    }

    private func moveLists(from source: IndexSet, to destination: Int) {
        viewModel.moveLists(from: source, to: destination)
    }
}
