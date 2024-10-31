import SwiftUI

struct Checkbox: View {
    @Binding var isChecked: Bool
    var onToggle: () -> Void

    var body: some View {
        Button(action: {
            isChecked.toggle()
            onToggle()  // Trigger the toggle action when the checkbox is clicked
        }) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isChecked ? .blue : .gray)
                .font(.system(size: 22))
        }
    }
}
