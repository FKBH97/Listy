import SwiftUI
import CoreData

class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    private var list: CustomList

    init(list: CustomList) {
        self.list = list
        fetchTasks()
    }

    func fetchTasks() {
        tasks = list.itemArray.compactMap { $0 as? TaskItem }
    }

    func deleteTasks(at offsets: IndexSet) {
        let tasksToDelete = offsets.map { tasks[$0] }
        tasksToDelete.forEach { list.managedObjectContext?.delete($0) }
        saveContext()
        fetchTasks()
    }

    func updateTaskCompletion(task: TaskItem, isCompleted: Bool) {
        task.isCompleted = isCompleted
        saveContext()
    }

    func reorderTasks(draggedTask: TaskItem, toIndex: Int) {
        guard let fromIndex = tasks.firstIndex(of: draggedTask) else { return }
        moveTasks(from: fromIndex, to: toIndex)
    }

    func moveTasks(from: Int, to: Int) {
        tasks.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        for (index, task) in tasks.enumerated() {
            task.order = Int16(index)
        }
        saveContext()
    }

    private func saveContext() {
        do {
            try list.managedObjectContext?.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
