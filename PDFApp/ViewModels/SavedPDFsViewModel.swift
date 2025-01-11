import SwiftUI
import RealmSwift
import PDFKit

class SavedPDFsViewModel: ObservableObject {
    @Published var savedPDFs: [RealmPDFModel] = []
    @Published var errorMessage: String?
    
    private var realm: Realm?
    
    init() {
        do {
            self.realm = try Realm()
            loadSavedPDFs()
        } catch {
            errorMessage = "Unable to initialize Realm: \(error.localizedDescription)"
        }
    }
    
    private func loadSavedPDFs() {
        guard let realm = realm else {
            errorMessage = "Realm is not initialized."
            return
        }
        
        let savedPDFsResults = realm.objects(RealmPDFModel.self)
        self.savedPDFs = Array(savedPDFsResults)
    }
    
    func deletePDF(_ pdf: RealmPDFModel) {
        guard let realm = realm else {
            errorMessage = "Realm is not initialized."
            return
        }
        
        guard let objectToDelete = realm.object(ofType: RealmPDFModel.self, forPrimaryKey: pdf.id) else {
            errorMessage = "Cannot find object in current Realm"
            return
        }
        
        do {
            try realm.write {
                realm.delete(objectToDelete)
            }
            loadSavedPDFs()
        } catch {
            errorMessage = "Failed to delete PDF: \(error.localizedDescription)"
        }
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
    
    func createThumbnail(_ pdfData: Data) -> some View {
        ThumbnailView(pdfData: pdfData)
    }
    
    
    func createMetadata(_ pdf: RealmPDFModel, _ pdfData: Data) -> MetadataRowData? {
        guard let _ = PDFDocument(data: pdfData) else { return nil }
        
        let formattedDate = dateFormatter.string(from: pdf.creationDate)
        return MetadataRowData(
            title: pdf.name,
            subtitle: "Date: \(formattedDate)"
        )
    }
    
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

