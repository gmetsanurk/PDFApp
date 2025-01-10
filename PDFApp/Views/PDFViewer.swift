import SwiftUI
import PDFKit

struct PDFViewer: View {
    let pdfDocument: PDFDocument

    var body: some View {
        PDFKitView(pdfDocument: pdfDocument)
            .edgesIgnoringSafeArea(.all)
    }
}

struct PDFKitView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
