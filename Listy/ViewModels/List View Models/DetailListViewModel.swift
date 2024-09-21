import Foundation
import CoreData

class DetailListViewModel: ObservableObject {
    @Published var items: [ListItem] = []
    private let context: NSManagedObjectContext
    private let list: CustomList

    init(list: CustomList, context: NSManagedObjectContext) {
        self.list = list
        self.context = context
        fetchItems()
    }

    func fetchItems() {
        let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
        request.predicate = NSPredicate(format: "customList == %@", list)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ListItem.order, ascending: true)]

        do {
            items = try context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }

    func updateTask(_ task: TaskItem) {
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Error updating task: \(error)")
        }
    }

    func moveTasks(from source: IndexSet, to destination: Int) {
        var revisedTasks: [TaskItem] = items.compactMap { $0 as? TaskItem }
        revisedTasks.move(fromOffsets: source, toOffset: destination)

        for reverseIndex in stride(from: revisedTasks.count - 1, through: 0, by: -1) {
            revisedTasks[reverseIndex].order = Int16(reverseIndex)
        }

        do {
            try context.save()
            fetchItems()
        } catch {
            print("Error moving tasks: \(error)")
        }
    }

    func filteredTasks(showCompleted: Bool) -> [TaskItem] {
        let tasks = items.compactMap { $0 as? TaskItem }
        return showCompleted ? tasks : tasks.filter { !$0.isCompleted }
    }

    func sortedTasks(by option: DetailListView.SortOption) -> [ListItem] {
        let tasks = filteredTasks(showCompleted: true)
        switch option {
        case .dueDate:
            return tasks.sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
        case .priority:
            return tasks.sorted { $0.priority > $1.priority }
        default:
            return tasks
        }
    }

    func deleteItems(at offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(context.delete)
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Error deleting items: \(error)")
        }
    }
}
