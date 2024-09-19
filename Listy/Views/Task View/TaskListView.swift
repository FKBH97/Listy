import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var list: CustomList
    @StateObject private var viewModel: DetailListViewModel
    @State private var newTaskText = ""
    @State private var draggedTask: TaskItem?

    init(list: CustomList) {
        self.list = list
        _viewModel = StateObject(wrappedValue: DetailListViewModel(list: list, context: list.managedObjectContext!))
    }

    var body: some View {
        VStack {
            HStack {
                TextField("New task", text: $newTaskText)
                Button(action: addTask) {
                    Label("Add Task", systemImage: "plus")
                }
            }
            .padding()

            List {
                ForEach(viewModel.items.compactMap { $0 as? TaskItem }) { task in
                    TaskRowView(task: task) // Removed viewModel here
                        .onDrag {
                            self.draggedTask = task
                            return NSItemProvider(object: task.wrappedText as NSString)
                        }
                        .onDrop(of: [.text], delegate: TaskDropDelegate(task: task, tasks: viewModel.items.compactMap { $0 as? TaskItem }, draggedTask: $draggedTask, viewModel: viewModel))
                }
                .onDelete(perform: deleteTasks)
                .onMove(perform: moveTasks)
            }
            .toolbar {
                EditButton()
            }
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
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { viewModel.items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                viewModel.fetchItems()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func moveTasks(from source: IndexSet, to destination: Int) {
        var revisedItems: [TaskItem] = viewModel.items.compactMap { $0 as? TaskItem }
        revisedItems.move(fromOffsets: source, toOffset: destination)

        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].order = Int16(reverseIndex)
        }

        do {
            try viewContext.save()
            viewModel.fetchItems()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
