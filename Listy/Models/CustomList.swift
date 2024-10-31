import Foundation
import CoreData

@objc(CustomList)
public class CustomList: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var isChecklist: Bool
    @NSManaged public var order: Int16
    @NSManaged public var items: NSSet?
    @NSManaged public var listType: String?
}

extension CustomList {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomList> {
        return NSFetchRequest<CustomList>(entityName: "CustomList")
    }

    // Wrapped properties for optional values
    var wrappedName: String {
        name ?? "Unknown List"
    }

    // Convenience method for accessing the list of items as an array
    var itemArray: [ListItem] {
        let set = items as? Set<ListItem> ?? []
        return set.sorted { $0.order < $1.order }
    }
}
