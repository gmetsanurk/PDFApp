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
