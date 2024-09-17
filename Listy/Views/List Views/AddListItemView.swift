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
    @State private var fetchedTmdbId: Int64 = 0 // Store tmdbId here
    @State private var isSearching = false
    @State private var saveError: IdentifiableError?

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
                mediaType = result.mediaType ?? "Unknown"
                fetchedTmdbId = Int64(result.id)
                print("Selected media with tmdbId: \(fetchedTmdbId)") // Log the selected tmdbId
                isSearching = false
            })
        }
        .alert(item: $saveError) { error in
            Alert(title: Text("Save Error"), message: Text(error.errorDescription ?? "Unable to save item"))
        }
    }

    private func saveItem() {
        guard fetchedTmdbId != 0 else {
            saveError = IdentifiableError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid tmdbId - Cannot save item."]))
            return
        }

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
            mediaItem.tmdbId = fetchedTmdbId
            print("Saving media item with tmdbId: \(mediaItem.tmdbId)") // Log tmdbId before saving
            newItem = mediaItem
        default:
            newItem = ListItem(context: context)
        }

        newItem.text = text
        newItem.customList = list

        do {
            try context.save()
            print("Item saved successfully with tmdbId: \(fetchedTmdbId)") // Log after successful save
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving item: \(error.localizedDescription)")
        }
    }
}
