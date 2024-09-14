import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: CustomList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.name, ascending: true)]
    ) var customLists: FetchedResults<CustomList>

    @State private var showingAddList = false

    var body: some View {
        NavigationView {
            List {
                ForEach(customLists, id: \.self) { list in
                    NavigationLink(destination: DetailListView(list: list)) {
                        Text(list.wrappedName)
                    }
                }
                .onDelete(perform: deleteList)
            }
            .navigationTitle("Your Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddList = true }) {
                        Label("Add List", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddList) {
                AddListView { name, isChecklist, listType in
                    addNewList(name: name, isChecklist: isChecklist, listType: listType)
                }
            }
        }
    }

    private func addNewList(name: String, isChecklist: Bool, listType: String) {
        let newList = CustomList(context: context)
        newList.id = UUID()
        newList.name = name
        newList.isChecklist = isChecklist
        newList.listType = listType // Use listType here
        newList.order = Int16(customLists.count)

        do {
            try context.save()
        } catch {
            print("Error saving new list: \(error.localizedDescription)")
        }
    }

    private func deleteList(at offsets: IndexSet) {
        for index in offsets {
            let listToDelete = customLists[index]
            context.delete(listToDelete)
        }

        do {
            try context.save()
        } catch {
            print("Error deleting list: \(error.localizedDescription)")
        }
    }
}
