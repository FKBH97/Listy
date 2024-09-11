import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var taskItem: TaskItem

    var body: some View {
        VStack {
            Text("Task: \(taskItem.text ?? "")")
            if let dueDate = taskItem.dueDate {
                Text("Due Date: \(dueDate, formatter: dateFormatter)")
            }
            Toggle(isOn: Binding(get: {
                taskItem.isCompleted
            }, set: { newValue in
                taskItem.isCompleted = newValue
            })) {
                Text("Completed")
            }
        }
        .navigationTitle("Task Details")
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
