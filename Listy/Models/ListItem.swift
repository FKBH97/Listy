import Foundation
import CoreData

extension ListItem {
    // Computed property to safely unwrap the text
    var wrappedText: String {
        text ?? "Unnamed Item"
    }
}
