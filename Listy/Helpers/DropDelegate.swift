import SwiftUI

struct TaskDropDelegate: DropDelegate {
    let task: TaskItem
    let tasks: [TaskItem]
    @Binding var draggedTask: TaskItem?
    let viewModel: DetailListViewModel

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedTask = draggedTask else { return false }
        guard let fromIndex = tasks.firstIndex(of: draggedTask),
              let toIndex = tasks.firstIndex(of: task) else { return false }
        
        viewModel.moveTasks(from: IndexSet(integer: fromIndex), to: toIndex)
        self.draggedTask = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedTask = draggedTask,
              let fromIndex = tasks.firstIndex(of: draggedTask),
              let toIndex = tasks.firstIndex(of: task) else { return }

        if fromIndex != toIndex {
            viewModel.moveTasks(from: IndexSet(integer: fromIndex), to: toIndex)
        }
    }
}

