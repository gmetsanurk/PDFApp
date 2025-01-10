import Foundation
import RealmSwift

class RealmPDFModel: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var name: String = ""
    @Persisted var dateCreated: Date = Date()
    @Persisted var pdfData: Data?
}
