import Foundation
import CoreData

extension CustomList {
    // MARK: - Computed Properties
    
    /// Safely access the name of the list
    var wrappedName: String {
        name ?? "Unnamed List"
    }
    
    /// Safely convert the category string to an enum
    var wrappedCategory: ListCategory {
        ListCategory(rawValue: category ?? "") ?? .general
    }
    
    /// Get a sorted array of list items
    var itemsArray: [ListItem] {
        let set = items as? Set<ListItem> ?? []
        return set.sorted { $0.order < $1.order }
    }

    // MARK: - Relationship Management Methods

    /// Add a new item to the list
    func addItem(_ text: String) {
        guard let context = managedObjectContext else { return }
        let newItem = ListItem(context: context)
        newItem.id = UUID()
        newItem.text = text
        newItem.order = Int16(itemsArray.count)
        addToItems(newItem)
        saveContext()
    }

    /// Remove an item from the list
    func removeItem(_ item: ListItem) {
        removeFromItems(item)
        managedObjectContext?.delete(item)
        reorderItems()
        saveContext()
    }

    /// Move an item within the list
    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        var items = itemsArray
        guard sourceIndex != destinationIndex,
              sourceIndex >= 0, sourceIndex < items.count,
              destinationIndex >= 0, destinationIndex < items.count else { return }
        
        let item = items.remove(at: sourceIndex)
        items.insert(item, at: destinationIndex)
        
        for (index, item) in items.enumerated() {
            item.order = Int16(index)
        }
        
        saveContext()
    }

    // MARK: - Private Helper Methods

    /// Reorder items after removal
    private func reorderItems() {
        for (index, item) in itemsArray.enumerated() {
            item.order = Int16(index)
        }
    }

    /// Save changes to Core Data
    private func saveContext() {
        do {
            try managedObjectContext?.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

// Enum for list categories
enum ListCategory: String, CaseIterable {
    case media = "Media"
    case quotes = "Quotes"
    case ideas = "Ideas"
    case general = "General"
    case tasks = "Tasks"
}
