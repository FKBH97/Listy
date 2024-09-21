import SwiftUI
import CoreData

struct ListEditView: View {
    @ObservedObject var list: CustomList
    @Environment(\.presentationMode) var presentationMode
    @State private var listName: String

    init(list: CustomList) {
        self.list = list
        _listName = State(initialValue: list.wrappedName)
    }

    var body: some View {
        Form {
            Section(header: Text("List Name")) {
                TextField("List Name", text: $listName)
            }

            Button("Save") {
                saveList()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Edit List")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func saveList() {
        list.name = listName
        do {
            try list.managedObjectContext?.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving list: \(error.localizedDescription)")
        }
    }
}
