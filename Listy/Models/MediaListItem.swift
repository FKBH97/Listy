// MediaListItem.swift
import Foundation
import CoreData

@objc(MediaListItem)
public class MediaListItem: ListItem {
  
    @NSManaged public var mediaType: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var mediaRating: Double
    @NSManaged public var overview: String?
    @NSManaged public var posterURL: String?
    @NSManaged public var tmdbId: Int32
}

extension MediaListItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaListItem> {
        return NSFetchRequest<MediaListItem>(entityName: "MediaListItem")
    }
}
