import UIKit

struct PDFFile: Identifiable {
    let id = UUID()
    let name: String
    let thumbnail: UIImage
    let creationDate: Date
}

