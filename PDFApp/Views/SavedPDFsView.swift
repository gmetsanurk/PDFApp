import SwiftUI

struct SavedPDFsView: View {
    @ObservedObject private var viewModel: SavedPDFsViewModel

    init(coordinator: any AppCoordinator) {
        self.viewModel = SavedPDFsViewModel(coordinator: coordinator)
    }

    var body: some View {
        NavigationView {
            List(viewModel.savedPDFs) { pdf in
                HStack {
                    if let pdfData = pdf.pdfData {
                        ThumbnailView(pdfData: pdfData)
                        
                        if let metadata = viewModel.createMetadata(pdf, pdfData) {
                            MetadataRow(data: metadata)
                        }
                    }
                }
                .contextMenu {
                    Button(action: {
                        viewModel.deletePDF(pdf)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    Button(action: {
                        viewModel.sharePDF(pdf)
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                .onTapGesture {
                    viewModel.showPDF(pdf)
                }
            }
            .navigationTitle("Saved PDFs")
        }
    }
}

