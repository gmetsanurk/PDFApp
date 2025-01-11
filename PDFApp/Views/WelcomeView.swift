import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                Text("With this app you can:")
                    .font(.title2)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Create PDFs")
                    }
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete PDFs.")
                    }
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share documents")
                    }
                }
                .font(.body)
                .padding()

                NavigationLink(destination: CreateEditPDFView()) {
                    Text("Let's begin!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.buttonPrimary)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
            }
            .navigationTitle("Welcome")
        }
    }
}

