import Foundation
import CoreData

@objc(ListItem)
public class ListItem: NSManagedObject {
    @NSManaged public var text: String?
    @NSManaged public var order: Int16
    @NSManaged public var customList: CustomList? // Relationship back to CustomList
}

extension ListItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    // Wrapped property for optional text
    var wrappedText: String {
        text ?? "No Text"
    }
}
