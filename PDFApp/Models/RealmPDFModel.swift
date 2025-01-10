import Foundation
import SwiftUI
import RealmSwift

class RealmPDFModel: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var name: String = ""
    @Persisted var thumbnailData: Data
    @Persisted var pdfData: Data?
    @Persisted var creationDate: Date
}
