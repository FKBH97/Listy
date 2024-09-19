import Foundation
import CoreData

@objc(TaskItem)
public class TaskItem: ListItem, Identifiable {
    @NSManaged public var dueDate: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var priority: Int16
    @NSManaged public var details: String?
    
    public var id: NSManagedObjectID {
        return objectID
    }

    var taskText: String {
        return text ?? "Unknown Task"
    }

    var wrappedDueDate: Date? {
        return dueDate
    }

    var wrappedPriority: Priority {
        get { Priority(rawValue: priority) ?? .none }
        set { priority = newValue.rawValue }
    }
    
    // Priority Enum
    enum Priority: Int16, CaseIterable {
        case none = 0
        case low = 1
        case medium = 2
        case high = 3
        
        var description: String {
            switch self {
            case .none: return "None"
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
    }
}

extension TaskItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }
}
