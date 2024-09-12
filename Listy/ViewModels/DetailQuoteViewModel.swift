import Foundation
import CoreData

class DetailedQuoteViewModel: ObservableObject, EditableItem {
    private let quoteItem: QuoteItem
    private let managedObjectContext: NSManagedObjectContext
    
    // Original values for undo functionality
    private var originalText: String = ""
    private var originalAuthor: String = ""
    private var originalLocation: String = ""
    private var originalQuoteContext: String = ""  // Renamed to avoid confusion
    
    @Published var text: String = ""
    @Published var author: String = ""
    @Published var location: String = ""
    @Published var quoteContext: String = ""  // Renamed to avoid confusion
    @Published var isSaving: Bool = false
    @Published var error: AppError?
    
    init(quoteItem: QuoteItem) {
        self.quoteItem = quoteItem
        self.managedObjectContext = quoteItem.managedObjectContext ?? PersistenceController.shared.container.viewContext
        
        loadData()
    }
    
    private func loadData() {
        originalText = quoteItem.text ?? ""
        originalAuthor = quoteItem.author ?? ""
        originalLocation = quoteItem.location ?? ""
        originalQuoteContext = quoteItem.context ?? ""
        
        text = originalText
        author = originalAuthor
        location = originalLocation
        quoteContext = originalQuoteContext  // Use renamed property
    }
    
    var hasChanges: Bool {
        text != originalText ||
        author != originalAuthor ||
        location != originalLocation ||
        quoteContext != originalQuoteContext  // Use renamed property
    }
    
    func validateInput() -> Result<Void, AppError> {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.validationError("Quote text cannot be empty"))
        }
        return .success(())
    }
    
    func saveChanges() -> Result<Void, AppError> {
        // First validate
        switch validateInput() {
        case .failure(let error):
            return .failure(error)
        case .success:
            break
        }
        
        // Check if there are actually changes to save
        guard hasChanges else {
            return .success(()) // No changes to save
        }
        
        // Proceed with save
        quoteItem.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        quoteItem.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
        quoteItem.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        quoteItem.context = quoteContext.trimmingCharacters(in: .whitespacesAndNewlines)  // Assign to Core Data property
        
        do {
            try managedObjectContext.save()  // Use managedObjectContext instead of context
            // Update original values after successful save
            loadData()
            return .success(())
        } catch {
            return .failure(.saveError(error.localizedDescription))
        }
    }
    
    func revertChanges() {
        text = originalText
        author = originalAuthor
        location = originalLocation
        quoteContext = originalQuoteContext  // Use renamed property
    }
}
