// TaskItem.swift
import Foundation
import CoreData

@objc(TaskItem)
public class TaskItem: ListItem {
    @NSManaged public var dueDate: Date?
    @NSManaged public var isCompleted: Bool
}

extension TaskItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }
}
