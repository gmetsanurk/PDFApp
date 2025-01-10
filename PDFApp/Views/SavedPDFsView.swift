import SwiftUI
import RealmSwift
import PDFKit

struct SavedPDFsView: View {
    @ObservedResults(RealmPDFModel.self) var savedPDFs

    var body: some View {
        NavigationView {
            List {
                ForEach(savedPDFs) { pdf in
                    HStack {
                        if let pdfData = pdf.pdfData {
                            addThumbnail(pdfData)
                            addMetadata(pdf, pdfData)
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

    // MARK: - Helper Methods

    @ViewBuilder
    private func addThumbnail(_ pdfData: Data) -> some View {
        if let image = UIImage(data: pdfData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
    }

    @ViewBuilder
    private func addMetadata(_ pdf: RealmPDFModel, _ pdfData: Data) -> some View {
        if let _ = PDFDocument(data: pdfData) {
            VStack(alignment: .leading) {
                Text(pdf.name)
                    .font(.headline)
                Text("Дата: \(pdf.creationDate, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

    private func deletePDF(_ pdf: RealmPDFModel) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(pdf)
        }
    }

    private func sharePDF(_ pdf: RealmPDFModel) {
        guard let data = pdf.pdfData else { return }
        let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)

        if let controller = UIApplication.shared.windows.first?.rootViewController {
            controller.present(activityController, animated: true, completion: nil)
        }
    }

    private func showPDF(_ pdf: RealmPDFModel) {
        guard let pdfData = pdf.pdfData,
              let pdfDocument = PDFDocument(data: pdfData) else {
            print("PDF data is invalid or cannot be read.")
            return
        }

        let pdfViewer = PDFViewer(pdfDocument: pdfDocument)
        if let controller = UIApplication.shared.windows.first?.rootViewController {
            controller.present(UIHostingController(rootView: pdfViewer), animated: true)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
