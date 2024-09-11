import Foundation
import CoreData

@objc(CustomList)
public class CustomList: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var isChecklist: Bool
    @NSManaged public var category: String?
    @NSManaged public var order: Int16
    @NSManaged public var items: NSSet? // Relationship to ListItem
}

extension CustomList {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomList> {
        return NSFetchRequest<CustomList>(entityName: "CustomList")
    }

    // Convenience methods to manage the relationship with ListItem
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ListItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ListItem)

    // Wrapped properties for optional values
    var wrappedName: String {
        name ?? "Unknown List"
    }

    var wrappedCategory: String {
        category ?? "General"
    }

    // Convenience method for accessing the list of items as an array
    var itemArray: [ListItem] {
        let set = items as? Set<ListItem> ?? []
        return set.sorted { $0.order < $1.order }
    }
}
