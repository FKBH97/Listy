import SwiftUI
import CoreData

struct EditItemView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let item: ListItem
    let updateItem: (String) -> Void
    
    @State private var itemText: String
    @State private var showingError = false
    
    init(item: ListItem, updateItem: @escaping (String) -> Void) {
        self.item = item
        self.updateItem = updateItem
        _itemText = State(initialValue: item.wrappedText)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Item Text", text: $itemText)
                    .accessibilityLabel("Item Text Field")
                    .accessibilityHint("Enter the text for the item.")
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .accessibilityLabel("Save Button")
                    .accessibilityHint("Saves the changes to the item and dismisses the view.")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .accessibilityLabel("Cancel Button")
                    .accessibilityHint("Dismisses the view without saving any changes.")
                }
            }
            .alert(isPresented: $showingError) {
                Alert(title: Text("Error"), message: Text("Item text cannot be empty"), dismissButton: .default(Text("OK")))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func saveItem() {
        guard !itemText.isEmpty else {
            showingError = true
            return
        }
        
        updateItem(itemText)
        presentationMode.wrappedValue.dismiss()
    }
}

// Preview for EditItemView
struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleItem = ListItem(context: context)
        sampleItem.text = "Sample Item"
        
        return NavigationView {
            EditItemView(item: sampleItem) { _ in
                // Preview doesn't actually update the item
            }
        }
    }
}
