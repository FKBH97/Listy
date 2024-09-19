import SwiftUI
import CoreData

struct DetailListView: View {
    @ObservedObject var list: CustomList
    @StateObject private var viewModel: DetailListViewModel
    @State private var showingAddItem = false
    @State private var sortOption: SortOption = .none

    enum SortOption {
        case none, dueDate, priority
    }

    init(list: CustomList) {
        self.list = list
        _viewModel = StateObject(wrappedValue: DetailListViewModel(list: list, context: list.managedObjectContext!))
    }

    var body: some View {
        List {
            ForEach(sortedItems, id: \.self) { item in
                listItemView(for: item)
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle(list.wrappedName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button("None") { sortOption = .none }
                    Button("Due Date") { sortOption = .dueDate }
                    Button("Priority") { sortOption = .priority }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddListItemView(list: list, viewModel: viewModel)
        }
        .onAppear {
            viewModel.fetchItems()
        }
    }

    private var sortedItems: [ListItem] {
        let items = viewModel.items
        switch sortOption {
        case .none:
            return items
        case .dueDate:
            return items.sorted {
                guard let task1 = $0 as? TaskItem, let task2 = $1 as? TaskItem else { return false }
                return (task1.dueDate ?? .distantFuture) < (task2.dueDate ?? .distantFuture)
            }
        case .priority:
            return items.sorted {
                guard let task1 = $0 as? TaskItem, let task2 = $1 as? TaskItem else { return false }
                return task1.priority > task2.priority
            }
        }
    }

    private func listItemView(for item: ListItem) -> some View {
        switch list.listType {
        case "quote":
            if let quoteItem = item as? QuoteItem {
                return AnyView(Text("\"\(quoteItem.text ?? "")\" - \(quoteItem.author ?? "")"))
            }
        case "task":
            if let taskItem = item as? TaskItem {
                return AnyView(
                    HStack {
                        Toggle(isOn: Binding(
                            get: { taskItem.isCompleted },
                            set: { newValue in
                                taskItem.isCompleted = newValue
                                try? list.managedObjectContext?.save()
                            }
                        )) {
                            Text(taskItem.text ?? "")
                                .strikethrough(taskItem.isCompleted)
                        }
                        Spacer()
                        if let dueDate = taskItem.dueDate {
                            Text(dueDate, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if taskItem.priority > 0 {
                            Text("Priority: \(taskItem.priority)")
                                .font(.caption)
                                .padding(4)
                                .background(Color.yellow.opacity(0.3))
                                .cornerRadius(4)
                        }
                    }
                )
            }
        case "media":
            if let mediaItem = item as? MediaListItem {
                return AnyView(
                    NavigationLink(destination: MediaDetailView(mediaItem: mediaItem)) {
                        Text("\(mediaItem.text ?? "") (\(mediaItem.mediaType ?? ""))")
                    }
                )
            }
        default:
            return AnyView(Text(item.text ?? ""))
        }
        return AnyView(EmptyView()) // Default empty view
    }

    private func deleteItems(at offsets: IndexSet) {
        withAnimation {
            offsets.map { viewModel.items[$0] }.forEach { item in
                list.managedObjectContext?.delete(item)
            }
            do {
                try list.managedObjectContext?.save()
                viewModel.fetchItems()  // Refresh the list after deletion
            } catch {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
    }
}
