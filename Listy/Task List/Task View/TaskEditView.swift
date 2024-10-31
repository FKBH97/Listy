import SwiftUI

struct TaskEditView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var task: TaskItem
    
    @State private var text: String
    @State private var dueDate: Date
    @State private var priority: Int16

    init(task: TaskItem) {
        self.task = task
        _text = State(initialValue: task.text ?? "Unknown Task")
        _dueDate = State(initialValue: task.dueDate ?? Date()) // Set a default if nil
        _priority = State(initialValue: task.priority)
    }
    
    var body: some View {
        Form {
            // TextField for task name
            TextField("Task", text: $text)
            
            // DatePicker for due date
            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
            
            // Picker for task priority
            Picker("Priority", selection: $priority) {
                Text("Low").tag(Int16(0))
                Text("Medium").tag(Int16(1))
                Text("High").tag(Int16(2))
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Save button to commit changes
            Button("Save") {
                saveTask()
            }
        }
        .navigationTitle("Edit Task")
    }
    
    // Function to save changes to the task
    private func saveTask() {
        task.text = text
        task.dueDate = dueDate
        task.priority = priority
        
        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving task: \(error)")
        }
    }
}
