import Foundation
import CoreData

class DetailListViewModel: ObservableObject {
    @Published var items: [ListItem] = []
    @Published var error: DetailListViewModelError?
    @Published var isLoading: Bool = false

    let list: CustomList
    private let context: NSManagedObjectContext

    init(list: CustomList, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.list = list
        self.context = context
        fetchItems()
    }

    // Fetches items from Core Data
    func fetchItems() {
        setLoading(true)
        context.perform { [weak self] in
            guard let self = self else { return }
            let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
            request.predicate = NSPredicate(format: "customList == %@", self.list)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ListItem.order, ascending: true)]

            do {
                let fetchedItems = try self.context.fetch(request)
                DispatchQueue.main.async {
                    self.items = fetchedItems
                    self.setLoading(false)
                }
            } catch {
                self.handleError(.fetchFailed(error.localizedDescription))
            }
        }
    }

    // Adds a generic item
    func addItem(text: String) {
        let newItem = ListItem(context: self.context)
        newItem.text = text
        newItem.customList = self.list
        newItem.order = Int16(self.items.count)

        do {
            try self.context.save()
            DispatchQueue.main.async {
                self.items.append(newItem)
            }
        } catch {
            self.handleError(.saveFailed(error.localizedDescription))
        }
    }

    // Adds a quote item with author, location, and context
    func addQuoteItem(text: String, author: String, location: String, context: String) {
        let newItem = QuoteItem(context: self.context)
        newItem.text = text
        newItem.author = author
        newItem.location = location
        newItem.context = context
        newItem.customList = self.list
        newItem.order = Int16(self.items.count)

        do {
            try self.context.save()
            DispatchQueue.main.async {
                self.items.append(newItem)
            }
        } catch {
            self.handleError(.saveFailed(error.localizedDescription))
        }
    }

    // Deletes items from the list
    func deleteItems(at offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(context.delete)
        do {
            try context.save()
            items.remove(atOffsets: offsets)
        } catch {
            handleError(.deleteFailed(error.localizedDescription))
        }
    }

    // Moves items in the list
    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        for (index, item) in items.enumerated() {
            item.order = Int16(index)
        }

        do {
            try context.save()
        } catch {
            handleError(.saveFailed(error.localizedDescription))
        }
    }

    // Helper methods to manage state and error handling
    private func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.isLoading = loading
        }
    }

    private func handleError(_ error: DetailListViewModelError) {
        DispatchQueue.main.async {
            self.error = error
            self.setLoading(false)
        }
    }
}
