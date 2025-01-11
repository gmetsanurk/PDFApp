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
                        viewModel.deletePDF(withId: pdf.id)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    Button(action: {
                        viewModel.sharePDF(pdf)
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {
                        viewModel.startMergeProcess(with: pdf)
                    }) {
                        Label("Merge", systemImage: "doc.on.doc")
                    }
                }
                .onTapGesture {
                    viewModel.showPDF(pdf)
                }
            }
            .navigationTitle("Saved PDFs")
            .sheet(isPresented: $viewModel.showMergePicker) {
                MergePicker(
                    savedPDFs: viewModel.savedPDFs,
                    onDocumentSelected: { secondPDF in
                        viewModel.mergePDFs(with: secondPDF)
                    }
                )
            }
        }
    }
}


