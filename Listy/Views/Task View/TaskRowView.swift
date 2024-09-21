import SwiftUI

struct TaskRowView: View {
    @ObservedObject var task: TaskItem
    var onUpdate: () -> Void
    @State private var isNavigatingToDetail = false

    var body: some View {
        HStack {
            // Checkbox for marking the task as completed
            Button(action: {
                task.isCompleted.toggle()
                try? task.managedObjectContext?.save()
                onUpdate()  // Trigger update when checkbox is toggled
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .blue : .gray)
                    .font(.system(size: 22))
            }
            .padding(.trailing, 8)
            .contentShape(Rectangle()) // Ensure the button responds to touches
            .highPriorityGesture(TapGesture().onEnded {
                // This high-priority gesture ensures the checkbox works before the row's tap is handled
                task.isCompleted.toggle()
                try? task.managedObjectContext?.save()
                onUpdate()
            })

            // Task content (text and due date) for navigation
            VStack(alignment: .leading) {
                Text(task.taskText)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)

                if let dueDate = task.wrappedDueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                isNavigatingToDetail = true  // Trigger navigation when task text is tapped
            }

            Spacer()

            // Priority label, if the task has priority
            if task.priority > 0 {
                Text("Priority: \(task.wrappedPriority.description)")
                    .font(.caption)
                    .padding(4)
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(4)
                    .allowsHitTesting(false) // Prevent interaction with the priority label
            }

            // Chevron for additional indication of navigation
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .allowsHitTesting(false)  // Prevent chevron from interfering with touch
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Make the entire row tappable for swipe actions
        .onTapGesture {
            isNavigatingToDetail = true // Trigger navigation when tapping anywhere else except checkbox
        }
        .navigationDestination(isPresented: $isNavigatingToDetail) {
            TaskDetailView(task: task)  // Navigate to TaskDetailView
        }
    }
}
