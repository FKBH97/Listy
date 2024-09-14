import SwiftUI
import CoreData

class DetailedQuoteViewModel: ObservableObject {
    @Published var text: String
    @Published var author: String
    @Published var location: String
    @Published var quoteContext: String
    @Published var isSaving = false
    @Published var error: IdentifiableError?

    private let quoteItem: QuoteItem
    
    init(quoteItem: QuoteItem) {
        self.quoteItem = quoteItem
        self.text = quoteItem.text ?? ""
        self.author = quoteItem.author ?? ""
        self.location = quoteItem.location ?? ""
        self.quoteContext = quoteItem.context ?? ""
    }
    
    func saveChanges() -> Result<Void, Error> {
        quoteItem.text = text
        quoteItem.author = author
        quoteItem.location = location
        quoteItem.context = quoteContext
        
        do {
            try quoteItem.managedObjectContext?.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func revertChanges() {
        text = quoteItem.text ?? ""
        author = quoteItem.author ?? ""
        location = quoteItem.location ?? ""
        quoteContext = quoteItem.context ?? ""
    }
}
