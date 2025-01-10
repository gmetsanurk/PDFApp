import SwiftUI
import PDFKit

struct CreateEditPDFView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var pdfDocument: PDFDocument?
    @State private var showingPDFViewer = false

    var body: some View {
        VStack {
            if selectedImages.isEmpty {
                Text("Choose PDF")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .padding()
                        }
                    }
                }
            }

            HStack {
                Button(action: generatePDF) {
                    Text("Create PDF")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(selectedImages.isEmpty)
            }

            if let _ = pdfDocument {
                Button(action: { showingPDFViewer = true }) {
                    Text("Show PDF")
                        .font(.headline)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingPDFViewer) {
            PDFViewer(pdfDocument: pdfDocument!)
        }
        .navigationTitle("Create PDF")
    }

    private func generatePDF() {
        let pdf = PDFDocument()
        for (index, image) in selectedImages.enumerated() {
            let page = PDFPage(image: image)
            pdf.insert(page!, at: index)
        }
        pdfDocument = pdf
    }
}
