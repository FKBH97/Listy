import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var list: CustomList
    @StateObject private var viewModel: DetailListViewModel
    @State private var showCompletedTasks = false
    @State private var newTaskText = ""

    init(list: CustomList) {
        self.list = list
        _viewModel = StateObject(wrappedValue: DetailListViewModel(list: list, context: list.managedObjectContext!))
    }

    var body: some View {
        VStack {
            // Add Task Input
            HStack {
                TextField("New task", text: $newTaskText)
                Button(action: addTask) {
                    Label("Add Task", systemImage: "plus")
                }
            }
            .padding()

            // Task List
            List {
                ForEach(viewModel.filteredTasks(showCompleted: showCompletedTasks), id: \.self) { task in
                    TaskRowView(task: task, onUpdate: {
                        viewModel.updateTask(task)
                    })
                }

                .onDelete(perform: deleteTasks)
                .onMove(perform: moveTasks)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Toggle("Show Completed", isOn: $showCompletedTasks)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .onAppear {
            viewModel.fetchItems()
        }
    }

    private func addTask() {
        withAnimation {
            let newTask = TaskItem(context: viewContext)
            newTask.text = newTaskText
            newTask.isCompleted = false
            newTask.order = Int16(viewModel.items.count)
            newTask.customList = list

            do {
                try viewContext.save()
                newTaskText = ""
                viewModel.fetchItems()
            } catch {
                print("Error adding task: \(error)")
            }
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        withAnimation {
            offsets.map { viewModel.items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
                viewModel.fetchItems()
            } catch {
                print("Error deleting task: \(error)")
            }
        }
    }

    private func moveTasks(from source: IndexSet, to destination: Int) {
        viewModel.moveTasks(from: source, to: destination)
    }
}
