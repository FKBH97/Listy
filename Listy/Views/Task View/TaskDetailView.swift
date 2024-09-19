import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: TaskItem
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Task Details")) {
                if isEditing {
                    // Editable Task fields
                    TextField("Task", text: Binding(
                        get: { task.wrappedText },
                        set: { newValue in task.text = newValue }
                    ))
                    
                    DatePicker("Due Date", selection: Binding(
                        get: { task.wrappedDueDate ?? Date() },
                        set: { newDate in task.dueDate = newDate }
                    ), displayedComponents: .date)
                    
                    DatePicker("Due Time", selection: Binding(
                        get: { task.wrappedDueDate ?? Date() },
                        set: { newTime in task.dueDate = newTime }
                    ), displayedComponents: .hourAndMinute)

                    Picker("Priority", selection: $task.priority) {
                        Text("None").tag(Int16(0))
                        Text("Low").tag(Int16(1))
                        Text("Medium").tag(Int16(2))
                        Text("High").tag(Int16(3))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                } else {
                    // Non-editable Task fields
                    Text(task.wrappedText)
                    if let dueDate = task.dueDate {
                        Text("Due: \(dueDate, style: .date)")
                        Text("Time: \(dueDate, style: .time)")
                    }
                    Text("Priority: \(task.wrappedPriority.description)")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing.toggle() }) {
                    Text(isEditing ? "Save" : "Edit")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Label("Close", systemImage: "xmark")
                }
            }
        }
    }
}
