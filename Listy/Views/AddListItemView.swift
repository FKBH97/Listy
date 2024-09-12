import SwiftUI

struct AddListItemView: View {
    @ObservedObject var list: CustomList
    @Environment(\.presentationMode) var presentationMode
    @State private var itemText: String = ""
    @State private var author: String = ""
    @State private var location: String = ""
    @State private var context: String = ""

    var onAdd: (String, String, String, String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quote")) {
                    TextField("Quote text", text: $itemText)
                }
                if list.wrappedCategory == ListCategory.quotes.rawValue {
                    Section(header: Text("Details")) {
                        TextField("Author", text: $author)
                        TextField("Location", text: $location)
                        TextField("Context", text: $context)
                    }
                }
            }
            .navigationBarTitle("Add Item", displayMode: .inline)
            .navigationBarItems(trailing: Button("Add") {
                if !itemText.isEmpty {
                    onAdd(itemText, author, location, context)
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}
