import SwiftUI

struct AddListView: View {
    // Environment to dismiss the view
    @Environment(\.presentationMode) var presentationMode
    
    // Closure to add a new list
    var addList: (String, Bool, ListCategory) -> Void
    
    // State variables for form inputs
    @State private var name = ""
    @State private var isChecklist = false
    @State private var category: ListCategory = .general
    
    // State variables for error handling
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        // Use Form instead of NavigationView for better integration
        Form {
            TextField("List Name", text: $name)
            
            Toggle("Is Checklist", isOn: $isChecklist)
            
            Picker("Category", selection: $category) {
                ForEach(ListCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            
            Section {
                Button("Save") {
                    saveList()
                }
            }
        }
        .navigationTitle("Add New List")
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
    
    private func saveList() {
        // Validate input
        guard !name.isEmpty else {
            showError("List name cannot be empty")
            return
        }
        
        // Add the new list
        addList(name, isChecklist, category)
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

// Preview provider for SwiftUI canvas
struct AddListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddListView { _, _, _ in
                // Preview doesn't actually add a list
            }
        }
    }
}
