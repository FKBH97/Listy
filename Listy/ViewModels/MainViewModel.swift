import Foundation
import CoreData
import Combine

enum MainViewModelError: Error, Identifiable {
    case fetchFailed
    case saveFailed
    case deleteFailed
    case unknown(String)
    
    var id: String { localizedDescription }
    
    var localizedDescription: String {
        switch self {
        case .fetchFailed:
            return "Failed to fetch lists"
        case .saveFailed:
            return "Failed to save changes"
        case .deleteFailed:
            return "Failed to delete list(s)"
        case .unknown(let message):
            return message
        }
    }
}

class MainViewModel: ObservableObject {
    @Published var lists: [CustomList] = []
    @Published var error: MainViewModelError?
    
    private var viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchLists()
        
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: viewContext)
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchLists()
            }
            .store(in: &cancellables)
    }
    
    func fetchLists() {
        let request: NSFetchRequest<CustomList> = CustomList.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CustomList.order, ascending: true)]
        
        do {
            lists = try viewContext.fetch(request)
        } catch {
            self.error = .fetchFailed
            print("Error fetching lists: \(error)")
        }
    }
    
    func addList(name: String, isChecklist: Bool, listType: String) {
        let newList = CustomList(context: viewContext)
        newList.id = UUID()
        newList.name = name
        newList.isChecklist = isChecklist
        newList.listType = listType // Updated from category to listType
        newList.order = Int16(lists.count)
        
        saveContext()
    }
    
    func deleteLists(at offsets: IndexSet) {
        let listsToDelete = offsets.map { lists[$0] }
        listsToDelete.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
            lists.remove(atOffsets: offsets)
        } catch {
            self.error = .deleteFailed
            print("Error deleting lists: \(error)")
        }
    }
    
    func moveLists(from source: IndexSet, to destination: Int) {
        var revisedItems = lists
        revisedItems.move(fromOffsets: source, toOffset: destination)
        
        for (index, item) in revisedItems.enumerated() {
            item.order = Int16(index)
        }
        
        saveContext()
    }
    
    private func saveContext() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
            fetchLists()
        } catch {
            self.error = .saveFailed
            print("Error saving context: \(error)")
            viewContext.rollback()
        }
    }
}
