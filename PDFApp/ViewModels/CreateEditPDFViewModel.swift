import SwiftUI
import PDFKit
import RealmSwift

class CreateEditPDFViewModel: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var pdfDocument: PDFDocument?
    @Published var saveSuccessMessage: AlertMessage?
    @Published var errorMessage: String?
    @Published var showingPhotoPicker = false
    @Published var showingPDFViewer = false

    private var realm: Realm?

    init() {
        do {
            self.realm = try Realm()
        } catch {
            self.errorMessage = "Unable to initialize Realm: \(error.localizedDescription)"
        }
    }

    func generatePDF() {
        guard !selectedImages.isEmpty else {
            errorMessage = "Please select at least one image to create a PDF."
            return
        }

        let pdf = PDFDocument()
        for (index, image) in selectedImages.enumerated() {
            if let page = PDFPage(image: image) {
                pdf.insert(page, at: index)
            }
        }
        pdfDocument = pdf
    }
    
    func savePDFToRealm(pdfDocument: PDFDocument, name: String) {
        guard let pdfData = extractPDFData(from: pdfDocument) else {
            errorMessage = "Unable to generate PDF data."
            return
        }

        let thumbnailData = generateThumbnailData(from: pdfDocument)
        let realmPDF = createRealmPDF(pdfData: pdfData, thumbnailData: thumbnailData, name: name)

        guard let realm = realm else {
            errorMessage = "Realm is not initialized."
            return
        }

        saveToRealm(realmPDF: realmPDF, in: realm)
    }
    
    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }

    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }

    func onButtonAddPicPressed() {
        showingPhotoPicker = true
    }

    func onShowPdfPressed() {
        showingPDFViewer = true
    }
}

extension CreateEditPDFViewModel {
    
    private func extractPDFData(from pdfDocument: PDFDocument) -> Data? {
        return pdfDocument.dataRepresentation()
    }
    
    private func generateThumbnailData(from pdfDocument: PDFDocument) -> Data? {
        guard let firstPage = pdfDocument.page(at: 0) else {
            return nil
        }
        let thumbnailSize = CGSize(width: 100, height: 100)
        let thumbnailImage = firstPage.thumbnail(of: thumbnailSize, for: .mediaBox)
        return thumbnailImage.pngData()
    }
    
    private func createRealmPDF(pdfData: Data, thumbnailData: Data?, name: String) -> RealmPDFModel {
        let realmPDF = RealmPDFModel()
        realmPDF.pdfData = pdfData
        realmPDF.thumbnailData = thumbnailData ?? Data()
        realmPDF.creationDate = Date()

        guard let realm = realm else {
            errorMessage = "Realm is not initialized."
            return realmPDF
        }

        let lastOrderNumber = realm.objects(RealmPDFModel.self).max(ofProperty: "orderNumber") as Int? ?? 0
        let newOrderNumber = lastOrderNumber + 1
        realmPDF.orderNumber = newOrderNumber
        realmPDF.name = "\(name) \(newOrderNumber)"

        return realmPDF
    }
    
    private func saveToRealm(realmPDF: RealmPDFModel, in realm: Realm) {
        do {
            try realm.write {
                realm.add(realmPDF)
            }
            saveSuccessMessage = AlertMessage(message: "PDF saved to Realm successfully!")
        } catch {
            errorMessage = "Error saving PDF to Realm: \(error.localizedDescription)"
        }
    }

}
