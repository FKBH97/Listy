import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: TaskItem
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var text: String
    @State private var dueDate: Date
    @State private var priority: Int16
    @State private var additionalDetails: String // Add additionalDetails state

    init(task: TaskItem) {
        self.task = task
        _text = State(initialValue: task.taskText) // Initialize with existing task text
        _dueDate = State(initialValue: task.dueDate ?? Date()) // Use existing due date or current date
        _priority = State(initialValue: task.priority) // Set the existing priority
        _additionalDetails = State(initialValue: task.additionalDetails ?? "") // Initialize additionalDetails
    }

    var body: some View {
        Form {
            // Task Text Section
            Section(header: Text("Task")) {
                TextField("Task", text: $text)
                    .accessibilityLabel("Task Field")
                    .accessibilityHint("Enter task description")
            }

            // Due Date Section
            Section(header: Text("Due Date")) {
                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                    .accessibilityLabel("Due Date Picker")
                    .accessibilityHint("Select the due date for the task")
            }

            // Priority Section
            Section(header: Text("Priority")) {
                Picker("Priority", selection: $priority) {
                    Text("None").tag(Int16(0))
                    Text("Low").tag(Int16(1))
                    Text("Medium").tag(Int16(2))
                    Text("High").tag(Int16(3))
                }
                .pickerStyle(SegmentedPickerStyle())
                .accessibilityLabel("Priority Picker")
                .accessibilityHint("Select the priority level for the task")
            }

            // Additional Details Section
            Section(header: Text("Additional Details")) {
                TextEditor(text: $additionalDetails)
                    .frame(height: 100) // Set a reasonable height for the TextEditor
                    .foregroundColor(.primary)
                    .accessibilityLabel("Additional Details")
                    .accessibilityHint("Enter any extra details for the task")
            }
        }
        .navigationTitle("Edit Task")
        .toolbar {
            // Save Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveTask() // Save the task details when pressed
                }
                .accessibilityLabel("Save Task Button")
                .accessibilityHint("Saves the changes made to the task")
            }
        }
    }

    // Save the task details to Core Data
    private func saveTask() {
        // Update task with new values
        task.setValue(text, forKey: "taskText")
        task.dueDate = dueDate
        task.priority = priority
        task.additionalDetails = additionalDetails // Save additional details

        // Save context to persist changes
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Dismiss the view on successful save
        } catch {
            print("Error saving task: \(error)")
        }
    }
}
