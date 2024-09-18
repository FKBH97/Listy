import Foundation
import CoreData

class DetailListViewModel: ObservableObject {
    @Published var items: [ListItem] = []
    @Published var error: AppError?
    @Published var isLoading = true // Added loading state

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

    func addQuoteItem(text: String, author: String, location: String, context: String) {
        let newItem = QuoteItem(context: self.context)
        newItem.text = text
        newItem.author = author
        newItem.location = location
        newItem.context = context
        newItem.customList = list

        do {
            try self.context.save()
            items.append(newItem)
        } catch {
            self.error = .saveError("Failed to save item: \(error.localizedDescription)")
        }
    }

    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            context.delete(item)
        }

        do {
            try context.save()
            items.remove(atOffsets: offsets)
        } catch {
            self.error = .deleteError("Failed to delete items: \(error.localizedDescription)")
        }
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
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
}
