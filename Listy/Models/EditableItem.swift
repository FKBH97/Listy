import Foundation

protocol EditableItem: AnyObject {
    var hasChanges: Bool { get }
    func validateInput() -> Result<Void, AppError>
    func saveChanges() -> Result<Void, AppError>
    func revertChanges()
}
