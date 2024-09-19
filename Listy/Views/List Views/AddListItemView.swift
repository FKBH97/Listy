import SwiftUI
import CoreData

struct AddListItemView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var list: CustomList
    @ObservedObject var viewModel: DetailListViewModel

    @State private var text = ""
    @State private var author = ""
    @State private var dueDate: Date = Date() // Ensure non-optional binding
    @State private var dueTime: Date = Date() // Set default time value
    @State private var priority: Int = 0
    @State private var mediaType = ""
    @State private var fetchedTmdbId: Int64 = 0
    @State private var isSearching = false
    @State private var saveError: IdentifiableError?

    var body: some View {
        Form {
            // Text input for item
            TextField("Item Text", text: $text)

            // Based on the list type, provide the appropriate fields
            switch list.listType {
            case "quote":
                TextField("Author", text: $author)
                
            case "task":
                // DatePicker for task due date
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                // DatePicker for task time
                DatePicker("Due Time", selection: $dueTime, displayedComponents: .hourAndMinute)
                
                // Priority picker with default value of 0
                Picker("Priority", selection: $priority) {
                    Text("None").tag(0)
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle()) // Segmented control style
                
            case "media":
                // Button to trigger media search
                Button("Search Media") {
                    isSearching = true
                }
                
            default:
                EmptyView()
            }

            // Save button to trigger save logic
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

    // Function to save the item based on the type
    private func saveItem() {
        let newItem: ListItem
        
        switch list.listType {
        case "quote":
            let quoteItem = QuoteItem(context: context)
            quoteItem.author = author
            newItem = quoteItem
            
        case "task":
            let taskItem = TaskItem(context: context)
            // Combine dueDate and dueTime
            let calendar = Calendar.current
            taskItem.dueDate = calendar.date(
                bySettingHour: calendar.component(.hour, from: dueTime),
                minute: calendar.component(.minute, from: dueTime),
                second: 0,
                of: dueDate
            )
            taskItem.priority = Int16(priority)
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
        
        // Save context
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
