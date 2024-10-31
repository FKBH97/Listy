import SwiftUI

struct ManualMediaEntryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var list: CustomList

    @State private var title = ""
    @State private var mediaType = ""
    @State private var releaseDate = Date()
    @State private var overview = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Media Type", text: $mediaType)
                DatePicker("Release Date", selection: $releaseDate, displayedComponents: .date)
                TextEditor(text: $overview)
            }
            .navigationTitle("Manual Media Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveManualEntry()
                    }
                }
            }
        }
    }

    private func saveManualEntry() {
        let newItem = MediaListItem(context: context)
        newItem.text = title
        newItem.mediaType = mediaType
        newItem.releaseDate = releaseDate
        newItem.overview = overview
        newItem.customList = list

        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving manual entry: \(error.localizedDescription)")
        }
    }
}
