import SwiftUI

struct AddListItemView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let list: CustomList
    var addItem: (String) -> Void
    
    @State private var itemText = ""
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        Form {
            TextField("Item Text", text: $itemText)
            
            Section {
                Button("Save") {
                    saveItem()
                }
            }
        }
        .navigationTitle("Add New Item")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert(isPresented: $showingError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func saveItem() {
        guard !itemText.isEmpty else {
            showError("Item text cannot be empty")
            return
        }
        
        addItem(itemText)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

struct AddListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleList = CustomList(context: context)
        sampleList.name = "Sample List"
        
        return NavigationView {
            AddListItemView(list: sampleList) { _ in
                // Preview doesn't actually add an item
            }
        }
    }
}
