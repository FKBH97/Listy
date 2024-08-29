import Foundation
import CoreData

enum DetailListViewModelError: Error {
    case fetchFailed
    case saveFailed
    case invalidItem
    case unknown(String)
}

class DetailListViewModel: ObservableObject {
    @Published var items: [ListItem] = []
    @Published var isLoading = false
    @Published var error: DetailListViewModelError?
    
    private let list: CustomList
    private let viewContext: NSManagedObjectContext

    init(list: CustomList) {
        self.list = list
        self.viewContext = list.managedObjectContext!
        fetchItems()
    }

    // Fetch items associated with the list
    func fetchItems() {
        isLoading = true
        let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
        request.predicate = NSPredicate(format: "customList == %@", list)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ListItem.order, ascending: true)]

        do {
            items = try viewContext.fetch(request)
            isLoading = false
        } catch {
            isLoading = false
            self.error = .fetchFailed
            print("Error fetching items: \(error)")
        }
    }

    // Add a new item to the list
    func addItem(_ text: String) throws {
        guard !text.isEmpty else {
            throw DetailListViewModelError.invalidItem
        }
        
        let newItem = ListItem(context: viewContext)
        newItem.id = UUID()
        newItem.text = text
        newItem.isChecked = false
        newItem.order = Int16(items.count)
        newItem.customList = list

        try saveContext()
        fetchItems()
    }

    // Delete an individual item
    func deleteItem(_ item: ListItem) throws {
        viewContext.delete(item)
        try saveContext()
        fetchItems()
    }

    // Delete items at specified offsets
    func deleteItems(at offsets: IndexSet) throws {
        offsets.map { items[$0] }.forEach(viewContext.delete)
        try saveContext()
        fetchItems()
    }

    // Move items from source indices to destination index
    func moveItems(from source: IndexSet, to destination: Int) throws {
        var revisedItems = items
        revisedItems.move(fromOffsets: source, toOffset: destination)
        for (index, item) in revisedItems.enumerated() {
            item.order = Int16(index)
        }
        try saveContext()
        fetchItems()
    }

    // Save changes to Core Data context
    func saveContext() throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                throw DetailListViewModelError.saveFailed
            }
        }
    }

    // Toggle the checked status of an item
    func toggleItemCheck(_ item: ListItem) throws {
        item.isChecked.toggle()
        try saveContext()
        fetchItems()
    }

    // Update the text of an item
    func updateItemText(_ item: ListItem, newText: String) throws {
        guard !newText.isEmpty else {
            throw DetailListViewModelError.invalidItem
        }
        
        item.text = newText
        try saveContext()
        fetchItems()
    }

    // Delete all items in the list
    func deleteAllItems() throws {
        items.forEach(viewContext.delete)
        try saveContext()
        fetchItems()
    }
    
    // Mark all items as checked or unchecked
    func markAllItems(checked: Bool) throws {
        items.forEach { $0.isChecked = checked }
        try saveContext()
        fetchItems()
    }
}
