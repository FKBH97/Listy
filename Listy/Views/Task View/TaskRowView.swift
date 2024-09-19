import SwiftUI

struct TaskRowView: View {
    @ObservedObject var task: TaskItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.taskText) // Use taskText directly
                    .font(.headline)
                
                if let dueDate = task.wrappedDueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                }
            }
            Spacer()
            if task.priority > 0 {
                Text("Priority: \(task.wrappedPriority.description)")
                    .font(.caption)
                    .padding(4)
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(4)
            }
        }
    }
}
