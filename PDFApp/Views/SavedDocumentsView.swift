import SwiftUI
import PDFKit

struct SavedDocumentsView: View {
    @State private var savedDocuments: [PDFFile] = []

    var body: some View {
        List {
            ForEach(savedDocuments) { file in
                HStack {
                    Image(uiImage: file.thumbnail)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text(file.name)
                            .font(.headline)
                        Text(file.creationDate, style: .date)
                            .font(.subheadline)
                    }
                }
                .contextMenu {
                    Button("Delete", role: .destructive) {
                        deleteDocument(file: file)
                    }
                    Button("Share") {
                        shareDocument(file: file)
                    }
                }
            }
        }
        .navigationTitle("Saved PDF")
        .onAppear(perform: loadSavedDocuments)
    }

    private func loadSavedDocuments() {
        let files = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        savedDocuments = files.map { url in
            let thumbnail = generateThumbnail(for: url)
            return PDFFile(name: url.lastPathComponent, thumbnail: thumbnail, creationDate: Date())
        }
    }

    private func generateThumbnail(for url: URL) -> UIImage {
        guard let document = PDFDocument(url: url),
              let page = document.page(at: 0) else { return UIImage() }

        return page.thumbnail(of: CGSize(width: 50, height: 50), for: .cropBox)
    }

    private func deleteDocument(file: PDFFile) {
    }

    private func shareDocument(file: PDFFile) {
    }
}
