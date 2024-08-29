import SwiftUI

@main
struct ListyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView(viewContext: persistenceController.container.viewContext)
        }
    }
}
