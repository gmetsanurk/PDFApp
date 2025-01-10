import Foundation
import RealmSwift

class PDFDocumentModel: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var dateCreated: Date
    @Persisted var pdfData: Data
}
