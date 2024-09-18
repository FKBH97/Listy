import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Listy")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let list = CustomList(context: context)
        list.name = "Sample List"
        list.order = 0

        let quoteItem = QuoteItem(context: context)
        quoteItem.text = "Sample Quote"
        quoteItem.author = "Author Name"
        quoteItem.context = "Context Information"
        quoteItem.customList = list

        try? context.save()

        return controller
    }()
}
