import SwiftUI

struct DetailedQuoteView: View {
    @StateObject private var viewModel: DetailedQuoteViewModel
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    
    init(quoteItem: QuoteItem) {
        _viewModel = StateObject(wrappedValue: DetailedQuoteViewModel(quoteItem: quoteItem))
    }
    
    var body: some View {
        Form {
            quoteSection
            authorSection
            locationSection
            quoteContextSection  // Renamed to avoid confusion
        }
        .navigationTitle("Quote Details")
        .toolbar { toolbarItems }
        .disabled(viewModel.isSaving)
        .alert(item: $viewModel.error) { error in
            Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
        }
        .overlay(savingOverlay)
    }
    
    private var quoteSection: some View {
        Section(header: Text("Quote")) {
            if isEditing {
                TextEditor(text: $viewModel.text)
            } else {
                Text(viewModel.text)
            }
        }
    }
    
    private var authorSection: some View {
        Section(header: Text("Author")) {
            if isEditing {
                TextField("Author", text: $viewModel.author)
            } else {
                Text(viewModel.author)
            }
        }
    }
    
    private var locationSection: some View {
        Section(header: Text("Location")) {
            if isEditing {
                TextField("Location", text: $viewModel.location)
            } else {
                Text(viewModel.location)
            }
        }
    }
    
    private var quoteContextSection: some View {  // Renamed to avoid confusion
        Section(header: Text("Context")) {
            if isEditing {
                TextEditor(text: $viewModel.quoteContext)  // Use renamed property
            } else {
                Text(viewModel.quoteContext)  // Use renamed property
            }
        }
    }
    
    @ViewBuilder
    private var savingOverlay: some View {
        if viewModel.isSaving {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    ProgressView("Saving...")
                        .padding()
                        .background(Color(uiColor: .systemBackground).opacity(0.7))  // Fixed Color issue
                        .cornerRadius(10)
                )
        }
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Save") {
                        saveChanges()
                    }
                } else {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                if isEditing {
                    Button("Cancel") {
                        cancelEditing()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        viewModel.isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Ensure UI updates before potentially intensive save operation
            let saveResult = viewModel.saveChanges()
            DispatchQueue.main.async {
                viewModel.isSaving = false
                switch saveResult {
                case .success:
                    isEditing = false // Exit edit mode on successful save
                case .failure(let error):
                    viewModel.error = error
                }
            }
        }
    }
    
    private func cancelEditing() {
        viewModel.revertChanges()
        withAnimation {
            isEditing = false
        }
    }
}
