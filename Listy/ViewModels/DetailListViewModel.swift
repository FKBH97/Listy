import Foundation
import CoreData

class DetailListViewModel: ObservableObject {
    @Published var items: [ListItem] = []
    @Published var error: DetailListViewModelError?
    @Published var isLoading: Bool = false

    private let list: CustomList
    private let context: NSManagedObjectContext

    init(list: CustomList, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.list = list
        self.context = context
        fetchItems() // Fetch items on initialization
    }

    func fetchItems() {
        isLoading = true
        let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
        request.predicate = NSPredicate(format: "customList == %@", list)

        do {
            items = try context.fetch(request)
            isLoading = false
        } catch {
            isLoading = false
            self.error = .fetchFailed(error.localizedDescription)
        }
    }

    func addItem(text: String) {
        isLoading = true
        do {
            let newItem = ListItem(context: context)
            newItem.text = text
            newItem.customList = list
            newItem.order = Int16(items.count)

            items.append(newItem)
            try context.save()
            fetchItems() // Refetch items to ensure view updates properly
            isLoading = false
        } catch {
            isLoading = false
            self.error = .saveFailed(error.localizedDescription)
        }
    }

    func toggleItemCheck(_ item: ListItem) {
        isLoading = true
        do {
            if let taskItem = item as? TaskItem {
                taskItem.isCompleted.toggle()
                try context.save()
            }
            fetchItems() // Refetch after state change
            isLoading = false
        } catch {
            isLoading = false
            self.error = .saveFailed(error.localizedDescription)
        }
    }

    func deleteItems(at offsets: IndexSet) {
        isLoading = true
        do {
            offsets.map { items[$0] }.forEach(context.delete)
            items.remove(atOffsets: offsets)
            try context.save()
            fetchItems() // Refetch after deletion
            isLoading = false
        } catch {
            isLoading = false
            self.error = .deleteFailed(error.localizedDescription)
        }
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        isLoading = true
        do {
            items.move(fromOffsets: source, toOffset: destination)
            for (index, item) in items.enumerated() {
                item.order = Int16(index)
            }
            try context.save()
            fetchItems() // Refetch after reordering
            isLoading = false
        } catch {
            isLoading = false
            self.error = .saveFailed(error.localizedDescription)
        }
    }

    func updateItemText(_ item: ListItem, newText: String) {
        isLoading = true
        do {
            item.text = newText
            try context.save()
            fetchItems() // Refetch after update
            isLoading = false
        } catch {
            isLoading = false
            self.error = .saveFailed(error.localizedDescription)
        }
    }
}

enum DetailListViewModelError: Error {
    case fetchFailed(String)
    case saveFailed(String)
    case deleteFailed(String)
    case unknown(String)

    var localizedDescription: String {
        switch self {
        case .fetchFailed(let message):
            return "Failed to fetch items: \(message)"
        case .saveFailed(let message):
            return "Failed to save items: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete items: \(message)"
        case .unknown(let message):
            return "An unknown error occurred: \(message)"
        }
    }
}

