import SwiftUI

struct AddListItemView: View {
    @ObservedObject var list: CustomList
    @Environment(\.presentationMode) var presentationMode
    @State private var itemText: String = ""
    var onAdd: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Item")) {
                    TextField("Item text", text: $itemText)
                }
            }
            .navigationBarTitle("Add Item", displayMode: .inline)
            .navigationBarItems(trailing: Button("Add") {
                if !itemText.isEmpty {
                    onAdd(itemText)
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}
