import SwiftUI
import PDFKit
import RealmSwift

class CreateEditPDFViewModel: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var pdfDocument: PDFDocument?
    @Published var saveSuccessMessage: AlertMessage?
    @Published var errorMessage: String?

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
        guard let pdfData = pdfDocument.dataRepresentation() else {
            errorMessage = "Unable to generate PDF data."
            return
        }

        let thumbnailData: Data?
        if let firstPage = pdfDocument.page(at: 0) {
            let thumbnailSize = CGSize(width: 100, height: 100)
            let thumbnailImage = firstPage.thumbnail(of: thumbnailSize, for: .mediaBox)
            thumbnailData = thumbnailImage.pngData()
        } else {
            thumbnailData = nil
        }

        let realmPDF = RealmPDFModel()
        realmPDF.name = name
        realmPDF.pdfData = pdfData
        realmPDF.thumbnailData = thumbnailData ?? Data()
        realmPDF.creationDate = Date()

        guard let realm = realm else {
            errorMessage = "Realm is not initialized."
            return
        }

        do {
            try realm.write {
                realm.add(realmPDF)
            }
            saveSuccessMessage = AlertMessage(message: "PDF saved to Realm successfully!")
        } catch {
            errorMessage = "Error saving PDF to Realm: \(error.localizedDescription)"
        }
    }

    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }

    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }
}


