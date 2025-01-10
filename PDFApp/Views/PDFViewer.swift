import SwiftUI
import PDFKit

struct PDFViewer: View {
    var pdfDocument: PDFDocument
    
    var body: some View {
        PDFKitView(pdfDocument: pdfDocument)
            .navigationTitle("View PDF")
            .navigationBarItems(trailing: Button(action: {
            }) {
                Text("Close")
            })
    }
}

struct PDFKitView: UIViewRepresentable {
    var pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdfDocument
    }
}
