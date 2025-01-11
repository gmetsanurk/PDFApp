import SwiftUI
import RealmSwift
import PDFKit

class SavedPDFsViewModel: ObservableObject {
    @Published var savedPDFs: [RealmPDFModel] = []
    @Published var errorMessage: String?
    @Published var showMergePicker = false
    
    private var selectedFirstPDF: RealmPDFModel?
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
        self.savedPDFs = Array(savedPDFsResults)
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

    
    func sharePDF(_ pdf: RealmPDFModel) {
        guard let data = pdf.pdfData else { return }
        coordinator.sharePdf(data: data)
    }
    
    func showPDF(_ pdf: RealmPDFModel) {
        guard let pdfData = pdf.pdfData,
              let pdfDocument = PDFDocument(data: pdfData) else {
            print("PDF data is invalid or cannot be read.")
            return
        }
        
        coordinator.showPdf(pdfDocument: pdfDocument)
    }
    
    func createMetadata(_ pdf: RealmPDFModel, _ pdfData: Data) -> MetadataRowData? {
        guard let _ = PDFDocument(data: pdfData) else { return nil }
        
        let formattedDate = dateFormatter.string(from: pdf.creationDate)
        return MetadataRowData(
            title: pdf.name,
            subtitle: "Date: \(formattedDate)"
        )
    }
}

extension SavedPDFsViewModel {
    
    func startMergeProcess(with firstPDF: RealmPDFModel) {
        selectedFirstPDF = firstPDF
        showMergePicker = true
    }
    
    func mergePDFs(with secondPDF: RealmPDFModel) {
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
        
        let thumbnailData: Data?
        if let firstPage = pdfDocument.page(at: 0) {
            let thumbnailSize = CGSize(width: 100, height: 100)
            let thumbnailImage = firstPage.thumbnail(of: thumbnailSize, for: .mediaBox)
            thumbnailData = thumbnailImage.pngData()
        } else {
            thumbnailData = nil
        }
        
        let realmPDF = RealmPDFModel()
        realmPDF.pdfData = pdfData
        realmPDF.thumbnailData = thumbnailData ?? Data()
        realmPDF.creationDate = Date()
        
        let lastOrderNumber = realm.objects(RealmPDFModel.self).max(ofProperty: "orderNumber") as Int? ?? 0
        let newOrderNumber = lastOrderNumber + 1
        realmPDF.orderNumber = newOrderNumber
        realmPDF.name = "Merged PDF Document \(newOrderNumber)"

        
        do {
            try realm.write {
                realm.add(realmPDF)
            }
            loadSavedPDFs()
        } catch {
            errorMessage = "Failed to save merged PDF: \(error.localizedDescription)"
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}


