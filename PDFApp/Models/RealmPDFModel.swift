import Foundation
import RealmSwift

class RealmPDFModel: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var name: String = ""
    @Persisted var thumbnailData: Data
    @Persisted var pdfData: Data?
    @Persisted var creationDate: Date
    @Persisted var orderNumber: Int = 0
}

struct SavedPDF: Identifiable {
    var id: ObjectId
    var name: String
    var pdfData: Data?
    var thumbnailData: Data?
    var creationDate: Date
    var orderNumber: Int
}
