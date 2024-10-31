// QuoteItem.swift
import Foundation
import CoreData

@objc(QuoteItem)
public class QuoteItem: ListItem {
    @NSManaged public var author: String?
    @NSManaged public var location: String?
    @NSManaged public var context: String?
}

extension QuoteItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuoteItem> {
        return NSFetchRequest<QuoteItem>(entityName: "QuoteItem")
    }
}
