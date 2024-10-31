import SwiftUI

@main
struct ListyApp: App {
    // Reference to the Core Data persistence controller
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // Set up the initial view and pass in the managed object context
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext) // No arguments passed here
        }
    }
}
