import Foundation

enum ListCategory: String, CaseIterable, Identifiable {
    case tasks
    case quotes
    case media
    case general
    
    var id: String { rawValue }
}
