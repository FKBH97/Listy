// ListManager.swift
import SwiftUI
import CoreData

class ListManager: ObservableObject {
    @Published var lists: [CustomList] = []
    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchLists()
    }

    // Fetch the lists sorted by order
    func fetchLists() {
        let request: NSFetchRequest<CustomList> = CustomList.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CustomList.order, ascending: true)]
        
        do {
            lists = try viewContext.fetch(request)
        } catch {
            print("Error fetching lists: \(error)")
        }
    }

    // Move lists and update their order
    func moveList(from source: IndexSet, to destination: Int) {
        lists.move(fromOffsets: source, toOffset: destination)
        for (index, list) in lists.enumerated() {
            list.order = Int16(index)
        }
        saveContext()
    }

    // Delete a list from Core Data
    func deleteList(_ list: CustomList) {
        viewContext.delete(list)
        saveContext()
        fetchLists()  // Refresh the list after deletion
    }

    // Save the context
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
