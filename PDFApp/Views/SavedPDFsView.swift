import SwiftUI
import RealmSwift
import PDFKit

struct SavedPDFsView: View {
    @ObservedResults(PDFDocumentModel.self) var savedPDFs

    var body: some View {
        NavigationView {
            List {
                ForEach(savedPDFs) { pdf in
                    HStack {
                        if let pdfData = pdf.pdfData,
                           let image = UIImage(data: pdfData),
                           let pdfDocument = PDFDocument(data: pdfData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(pdf.name)
                                    .font(.headline)
                                Text("Дата: \(pdf.dateCreated, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            deletePDF(pdf)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                        Button(action: {
                            sharePDF(pdf)
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                    .onTapGesture {
                        showPDF(pdf)
                    }
                }
            }
            .navigationTitle("Saved PDF")
        }
    }

    private func deletePDF(_ pdf: PDFDocumentModel) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(pdf)
        }
    }

    private func sharePDF(_ pdf: PDFDocumentModel) {
        let data = pdf.pdfData
        let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)

        if let controller = UIApplication.shared.windows.first?.rootViewController {
            controller.present(activityController, animated: true, completion: nil)
        }
    }

    private func showPDF(_ pdf: PDFDocumentModel) {
        guard let pdfData = pdf.pdfData,
              let pdfDocument = PDFDocument(data: pdfData) else {
            return
        }

        let pdfViewer = PDFViewer(pdfDocument: pdfDocument)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
