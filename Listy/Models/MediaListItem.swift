// MediaListItem.swift
import Foundation
import CoreData

@objc(MediaListItem)
public class MediaListItem: ListItem {
    @NSManaged public var mediaType: String?
    @NSManaged public var source: String?
    @NSManaged public var mediaRating: Double
}

extension MediaListItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaListItem> {
        return NSFetchRequest<MediaListItem>(entityName: "MediaListItem")
    }
}
