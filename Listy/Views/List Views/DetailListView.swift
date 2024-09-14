import SwiftUI
import CoreData

struct DetailListView: View {
    @ObservedObject var list: CustomList
    @State private var showingAddItem = false

    var body: some View {
        List {
            ForEach(list.itemArray, id: \.self) { item in
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
        }
        .sheet(isPresented: $showingAddItem) {
            AddListItemView(list: list) // Pass the list directly
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
                return AnyView(Toggle(taskItem.text ?? "", isOn: Binding(
                    get: { taskItem.isCompleted },
                    set: { newValue in
                        taskItem.isCompleted = newValue
                        try? list.managedObjectContext?.save()
                    }
                )))
            }
        case "media":
            if let mediaItem = item as? MediaListItem {
                return AnyView(Text("\(mediaItem.text ?? "") (\(mediaItem.mediaType ?? ""))"))
            }
        default:
            return AnyView(Text(item.text ?? ""))
        }
        return AnyView(EmptyView()) // To ensure matching return types
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = list.itemArray[index]
            list.managedObjectContext?.delete(item)
        }
        do {
            try list.managedObjectContext?.save()
        } catch {
            print("Error deleting item: \(error.localizedDescription)")
        }
    }
}
