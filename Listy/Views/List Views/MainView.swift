import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: CustomList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.order, ascending: true)]
    ) var customLists: FetchedResults<CustomList>

    @State private var showingAddList = false
    @State private var showingDeleteConfirmation = false
    @State private var listToDelete: CustomList?

    var body: some View {
        NavigationView {
            List {
                ForEach(customLists, id: \.self) { list in
                    NavigationLink(destination: DetailListView(list: list)) {
                        Text(list.wrappedName)
                    }
                }
                .onDelete(perform: promptDelete)
                .onMove(perform: moveList)
            }
            .navigationTitle("Your Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
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
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Delete List"),
                    message: Text("Are you sure you want to delete this list? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let list = listToDelete {
                            deleteList(list: list)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func addNewList(name: String, isChecklist: Bool, listType: String) {
        let newList = CustomList(context: context)
        newList.id = UUID()
        newList.name = name
        newList.isChecklist = isChecklist
        newList.listType = listType
        newList.order = Int16(customLists.count)

        do {
            try context.save()
        } catch {
            print("Error saving new list: \(error.localizedDescription)")
        }
    }

    private func promptDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            listToDelete = customLists[index]
            showingDeleteConfirmation = true
        }
    }

    private func deleteList(list: CustomList) {
        context.delete(list)
        do {
            try context.save()
        } catch {
            print("Error deleting list: \(error.localizedDescription)")
        }
    }

    private func moveList(from source: IndexSet, to destination: Int) {
        var revisedLists = customLists.map { $0 }
        revisedLists.move(fromOffsets: source, toOffset: destination)
        for (index, list) in revisedLists.enumerated() {
            list.order = Int16(index)
        }
        do {
            try context.save()
        } catch {
            print("Error saving moved lists: \(error.localizedDescription)")
        }
    }
}
