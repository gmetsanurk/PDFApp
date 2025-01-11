import SwiftUI

struct MergePicker: View {
    let savedPDFs: [RealmPDFModel]
    let onDocumentSelected: (RealmPDFModel) -> Void

    var body: some View {
        NavigationView {
            List(savedPDFs) { pdf in
                Button(action: {
                    onDocumentSelected(pdf)
                }) {
                    Text(pdf.name)
                }
            }
            .navigationTitle("Select PDF to Merge")
        }
    }
}
