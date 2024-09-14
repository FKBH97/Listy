import SwiftUI
import CoreData

struct AddListItemView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var list: CustomList
    @StateObject private var viewModel = MediaSearchViewModel()

    @State private var text = ""
    @State private var author = ""
    @State private var dueDate = Date()
    @State private var mediaType = ""
    @State private var isSearching = false

    var body: some View {
        Form {
            TextField("Item Text", text: $text)

            switch list.listType {
            case "quote":
                TextField("Author", text: $author)
            case "task":
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
            case "media":
                Button("Search Media") {
                    isSearching = true
                }
            default:
                EmptyView()
            }

            Button("Save") {
                saveItem()
            }
        }
        .navigationTitle("Add New Item")
        .sheet(isPresented: $isSearching) {
            MediaSearchView(onSelect: { result in
                text = result.displayTitle
                mediaType = result.mediaType
                isSearching = false
            })
        }
    }

    private func saveItem() {
        let newItem: ListItem

        switch list.listType {
        case "quote":
            let quoteItem = QuoteItem(context: context)
            quoteItem.author = author
            newItem = quoteItem
        case "task":
            let taskItem = TaskItem(context: context)
            taskItem.dueDate = dueDate
            newItem = taskItem
        case "media":
            let mediaItem = MediaListItem(context: context)
            mediaItem.mediaType = mediaType
            newItem = mediaItem
        default:
            newItem = ListItem(context: context)
        }

        newItem.text = text
        newItem.customList = list

        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving item: \(error.localizedDescription)")
        }
    }
}
