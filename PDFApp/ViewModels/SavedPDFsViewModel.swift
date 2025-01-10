import SwiftUI
import RealmSwift
import PDFKit

class SavedPDFsViewModel: ObservableObject {
    @Published var savedPDFs: [RealmPDFModel] = []
    
    private var realm: Realm

    init() {
        self.realm = try! Realm()
        loadSavedPDFs()
    }

    private func loadSavedPDFs() {
        let savedPDFsResults = realm.objects(RealmPDFModel.self)
        self.savedPDFs = Array(savedPDFsResults)
    }

    func deletePDF(_ pdf: RealmPDFModel) {
        guard let objectToDelete = realm.object(ofType: RealmPDFModel.self, forPrimaryKey: pdf.id) else {
            print("Cannot find object in current Realm")
            return
        }

        try! realm.write {
            realm.delete(objectToDelete)
        }

        loadSavedPDFs()
    }

    func sharePDF(_ pdf: RealmPDFModel) {
        guard let data = pdf.pdfData else { return }
        let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)

        if let controller = UIApplication.shared.windows.first?.rootViewController {
            controller.present(activityController, animated: true, completion: nil)
        }
    }

    func showPDF(_ pdf: RealmPDFModel) {
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

    func addThumbnail(_ pdfData: Data) -> Image? {
        if let image = UIImage(data: pdfData) {
            return Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle()) as? Image
        }
        return nil
    }

    func addMetadata(_ pdf: RealmPDFModel, _ pdfData: Data) -> some View {
        if let _ = PDFDocument(data: pdfData) {
            return AnyView(
                VStack(alignment: .leading) {
                    Text(pdf.name)
                        .font(.headline)
                    Text("Date: \(pdf.creationDate, formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            )
        }
        return AnyView(EmptyView())
    }


    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

