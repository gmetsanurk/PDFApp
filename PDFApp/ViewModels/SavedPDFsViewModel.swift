import SwiftUI
import RealmSwift
import PDFKit

class SavedPDFsViewModel: ObservableObject {
    @Published var savedPDFs: [SavedPDF] = []
    @Published var errorMessage: String?
    @Published var showMergePicker = false
    
    var selectedFirstPDF: RealmPDFModel?
    private var realm: Realm?
    let coordinator: any AppCoordinator
    
    init(coordinator: any AppCoordinator) {
        self.coordinator = coordinator
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
        self.savedPDFs = convertToSavedPDFs(Array(savedPDFsResults))
    }

    func convertToSavedPDFs(_ realmPDFs: [RealmPDFModel]) -> [SavedPDF] {
        return realmPDFs.map { realmPDF in
            return SavedPDF(
                id: realmPDF.id,
                name: realmPDF.name,
                pdfData: realmPDF.pdfData,
                thumbnailData: realmPDF.thumbnailData,
                creationDate: realmPDF.creationDate,
                orderNumber: realmPDF.orderNumber
            )
        }
    }

    func deletePDF(withId id: ObjectId) {
        guard let realm = realm else {
            errorMessage = "Realm is not initialized."
            return
        }
        
        guard let objectToDelete = realm.object(ofType: RealmPDFModel.self, forPrimaryKey: id) else {
            errorMessage = "Cannot find object in current Realm."
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
    
    func sharePDF(_ pdf: SavedPDF) {
        guard let realmPDF = realm?.object(ofType: RealmPDFModel.self, forPrimaryKey: pdf.id),
              let data = realmPDF.pdfData else { return }
        coordinator.sharePdf(data: data)
    }
    
    func showPDF(_ pdf: SavedPDF) {
        guard let realmPDF = realm?.object(ofType: RealmPDFModel.self, forPrimaryKey: pdf.id),
              let pdfData = realmPDF.pdfData,
              let pdfDocument = PDFDocument(data: pdfData) else {
            print("PDF data is invalid or cannot be read.")
            return
        }
        
        coordinator.showPdf(pdfDocument: pdfDocument)
    }
    
    func createMetadata(_ pdf: SavedPDF, _ pdfData: Data) -> MetadataRowData? {
        guard let _ = PDFDocument(data: pdfData) else { return nil }
        
        let formattedDate = dateFormatter.string(from: pdf.creationDate)
        return MetadataRowData(
            title: pdf.name,
            subtitle: "Date: \(formattedDate)"
        )
    }
}

extension SavedPDFsViewModel {
    
    func startMergeProcess(with firstPDF: SavedPDF) {
        guard let realmFirstPDF = realm?.object(ofType: RealmPDFModel.self, forPrimaryKey: firstPDF.id) else { return }
        selectedFirstPDF = realmFirstPDF
        showMergePicker = true
    }

    func mergePDFs(with secondPDF: SavedPDF) {
        guard let firstPDFData = selectedFirstPDF?.pdfData,
              let secondPDFData = secondPDF.pdfData,
              let firstPDF = PDFDocument(data: firstPDFData),
              let secondPDF = PDFDocument(data: secondPDFData) else {
            errorMessage = "Failed to load PDF data for merging."
            return
        }
        
        let mergedPDF = PDFDocument()
        (0..<firstPDF.pageCount).forEach { index in
            if let page = firstPDF.page(at: index) {
                mergedPDF.insert(page, at: mergedPDF.pageCount)
            }
        }

        (0..<secondPDF.pageCount).forEach { index in
            if let page = secondPDF.page(at: index) {
                mergedPDF.insert(page, at: mergedPDF.pageCount)
            }
        }
        
        saveMergedPDF(mergedPDF)
        selectedFirstPDF = nil
        showMergePicker = false
    }
    
    private func saveMergedPDF(_ pdfDocument: PDFDocument) {
        guard let pdfData = pdfDocument.dataRepresentation(),
              let realm = realm else { return }
        
        let thumbnailData = generateThumbnailData(from: pdfDocument)
        let realmPDF = createRealmPDFModel(with: pdfData, thumbnailData: thumbnailData, in: realm)
        
        saveToRealm(realmPDF, in: realm)
    }
    
    private func generateThumbnailData(from pdfDocument: PDFDocument) -> Data? {
        guard let firstPage = pdfDocument.page(at: 0) else { return nil }
        let thumbnailSize = CGSize(width: 100, height: 100)
        let thumbnailImage = firstPage.thumbnail(of: thumbnailSize, for: .mediaBox)
        return thumbnailImage.pngData()
    }
    
    private func saveToRealm(_ realmPDF: RealmPDFModel, in realm: Realm) {
        do {
            try realm.write {
                realm.add(realmPDF)
            }
            loadSavedPDFs()
        } catch {
            errorMessage = "Failed to save merged PDF: \(error.localizedDescription)"
        }
    }
    
    private func createRealmPDFModel(with pdfData: Data, thumbnailData: Data?, in realm: Realm) -> RealmPDFModel {
        let realmPDF = RealmPDFModel()
        realmPDF.pdfData = pdfData
        realmPDF.thumbnailData = thumbnailData ?? Data()
        realmPDF.creationDate = Date()
        
        let lastOrderNumber = realm.objects(RealmPDFModel.self).max(ofProperty: "orderNumber") as Int? ?? 0
        realmPDF.orderNumber = lastOrderNumber + 1
        realmPDF.name = "Merged PDF Document \(realmPDF.orderNumber)"
        
        return realmPDF
    }

    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
