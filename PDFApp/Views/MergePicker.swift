import SwiftUI

struct MergePicker: View {
    var availablePDFs: [SavedPDF]
    var selectedFirstPDF: RealmPDFModel?
    var onDocumentSelected: (SavedPDF) -> Void

    var body: some View {
        NavigationView {
            List(availablePDFs.filter { $0.id != selectedFirstPDF?.id }) { pdf in
                HStack {
                    if let thumbnailData = pdf.thumbnailData {
                        ThumbnailView(pdfData: thumbnailData)
                    }
                    Text(pdf.name)
                }
                .onTapGesture {
                    onDocumentSelected(pdf)
                }
            }
            .navigationTitle("Select PDF to Merge")
        }
    }
}
