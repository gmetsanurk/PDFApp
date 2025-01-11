import SwiftUI
import PDFKit
import RealmSwift

class CreateEditPDFViewModel: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var pdfDocument: PDFDocument?
    @Published var saveSuccessMessage: AlertMessage?

    private var realm: Realm

    init() {
        self.realm = try! Realm()
    }

    func generatePDF() {
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
            print("Unable to generate PDF data.")
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

        try! realm.write {
            realm.add(realmPDF)
        }

        saveSuccessMessage = AlertMessage(message: "PDF saved to Realm successfully!")
    }

    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }

    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }
}

