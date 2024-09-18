import SwiftUI

struct ErrorView: View {
    let error: IdentifiableError
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Error")
                .font(.title)
                .foregroundColor(.red)
            Text(error.errorDescription ?? "An unknown error occurred")
                .multilineTextAlignment(.center)
            Button("Retry") {
                retryAction()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
