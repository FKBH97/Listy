import SwiftUI
import CoreData

struct AddListItemView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var list: CustomList
    @ObservedObject var viewModel: DetailListViewModel

    @State private var text = ""
    @State private var author = ""
    @State private var dueDate: Date? = nil // Optional dueDate
    @State private var showDatePicker = false // Toggle for showing DatePicker
    @State private var priority: Int = 0
    @State private var additionalDetails = ""
    @State private var mediaType = ""
    @State private var fetchedTmdbId: Int64 = 0
    @State private var isSearching = false
    @State private var saveError: IdentifiableError?

    var body: some View {
        Form {
            TextField("Item Text", text: $text)

            switch list.listType {
            case "quote":
                TextField("Author", text: $author)
                
            case "task":
                // Toggle to show/hide the DatePicker
                Toggle("Set Due Date", isOn: $showDatePicker.animation())
                
                if showDatePicker {
                    DatePicker("Due Date", selection: Binding(
                        get: { dueDate ?? Date() }, // Provide a default date if nil
                        set: { dueDate = $0 }       // Update the optional dueDate
                    ), displayedComponents: .date)
                }

                Picker("Priority", selection: $priority) {
                    Text("None").tag(0)
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Section(header: Text("Additional Details")) {
                    TextEditor(text: $additionalDetails)
                        .frame(height: 100)
                        .foregroundColor(.secondary)
                }
                
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
                isSearching = false
            })
        }
        .alert(item: $saveError) { error in
            Alert(title: Text("Save Error"), message: Text(error.errorDescription ?? "Unable to save item"))
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
            taskItem.dueDate = showDatePicker ? dueDate : nil // Set dueDate or leave it nil
            taskItem.priority = Int16(priority)
            taskItem.additionalDetails = additionalDetails
            newItem = taskItem
            
        case "media":
            let mediaItem = MediaListItem(context: context)
            mediaItem.mediaType = mediaType
            mediaItem.tmdbId = fetchedTmdbId
            newItem = mediaItem
            
        default:
            newItem = ListItem(context: context)
        }
        
        newItem.text = text
        newItem.customList = list
        
        do {
            try context.save()
            viewModel.fetchItems() // Refresh the list after saving
            presentationMode.wrappedValue.dismiss()
        } catch {
            saveError = IdentifiableError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to save item."]))
            print("Error saving item: \(error.localizedDescription)")
        }
    }
}
