import SwiftUI

struct AddTaskItemView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var list: CustomList

    @State private var text = ""
    @State private var dueDate = Date()

    var body: some View {
        NavigationView {
            Form {
                TextField("Task", text: $text)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                Button("Save") {
                    saveTask()
                }
            }
            .navigationTitle("Add Task")
        }
    }

    private func saveTask() {
        let newTask = TaskItem(context: context)
        newTask.text = text
        newTask.dueDate = dueDate
        newTask.isCompleted = false
        newTask.customList = list

        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving task: \(error.localizedDescription)")
        }
    }
}
