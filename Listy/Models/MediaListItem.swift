import Foundation
import CoreData

@objc(MediaListItem)
public class MediaListItem: ListItem {
    @NSManaged public var mediaType: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var mediaRating: Double
    @NSManaged public var posterURL: String?
    @NSManaged public var tmdbId: Int64  // Ensure this matches your Core Data model
    @NSManaged public var overview: String?

    // Custom init to log tmdbId when a new MediaListItem is created
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        // Check if tmdbId is properly assigned when the object is first created
        print("MediaListItem created with tmdbId: \(tmdbId)")
    }

    // Function to log when tmdbId is updated
    public func setTmdbId(id: Int64) {
        self.tmdbId = id
        print("tmdbId has been set to: \(tmdbId)")
    }
}

extension MediaListItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaListItem> {
        return NSFetchRequest<MediaListItem>(entityName: "MediaListItem")
    }
}
