import SwiftUI
import CoreData

struct AddListView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var isChecklist = false
    
    @State private var listType = "quote" // Default to 'quote'
    
    @State private var showingError = false
    @State private var errorMessage = ""

    var addList: (String, Bool, String) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("List Name", text: $name)

                Toggle("Is Checklist", isOn: $isChecklist)

                Picker("List Type", selection: $listType) {
                    Text("Quote").tag("quote")
                    Text("Media").tag("media")
                    Text("Task").tag("task")
                }

                Button("Save") {
                    saveList()
                }
            }
            .navigationTitle("Add New List")
            .alert(isPresented: $showingError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func saveList() {
        guard !name.isEmpty else {
            showError("List name cannot be empty")
            return
        }

        addList(name, isChecklist, listType) // Pass the selected listType only
        presentationMode.wrappedValue.dismiss()
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}
