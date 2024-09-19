import Foundation
import CoreData

class DetailListViewModel: ObservableObject {
    @Published var items: [ListItem] = []
    @Published var error: AppError?
    @Published var isLoading = true

    let context: NSManagedObjectContext
    let list: CustomList

    init(list: CustomList, context: NSManagedObjectContext) {
        self.list = list
        self.context = context
        fetchItems()
    }

    func fetchItems() {
        isLoading = true
        let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
        request.predicate = NSPredicate(format: "customList == %@", list)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ListItem.order, ascending: true)]

        do {
            items = try context.fetch(request)
            isLoading = false
        } catch {
            self.error = .fetchError("Failed to fetch items: \(error.localizedDescription)")
            isLoading = false
        }
    }

    func updateTaskCompletion(task: TaskItem, isCompleted: Bool) {
        task.isCompleted = isCompleted
        saveContext()
    }

    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            context.delete(item)
        }

        do {
            try context.save()
            fetchItems()
        } catch {
            self.error = .deleteError("Failed to delete items: \(error.localizedDescription)")
        }
    }

    func moveTasks(from sourceIndex: Int, to destinationIndex: Int) {
        items.move(fromOffsets: IndexSet(integer: sourceIndex), toOffset: destinationIndex)
        saveOrder()
    }

    private func saveOrder() {
        for (index, item) in items.enumerated() {
            item.order = Int16(index)
        }

        do {
            try context.save()
        } catch {
            self.error = .saveError("Failed to save item order: \(error.localizedDescription)")
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            self.error = .saveError("Failed to save task completion: \(error.localizedDescription)")
        }
    }
}
