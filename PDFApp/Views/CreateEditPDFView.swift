import SwiftUI
import PDFKit
import RealmSwift

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}


struct CreateEditPDFView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var pdfDocument: PDFDocument?
    @State private var showingPDFViewer = false
    @State private var showingPhotoPicker = false
    @State private var saveSuccessMessage: AlertMessage?

    var body: some View {
        VStack {
            if selectedImages.isEmpty {
                Text("Choose pic for editing PDF")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .padding()
                        }
                    }
                }
            }

            HStack {
                Button(action: { showingPhotoPicker = true }) {
                    Text("Add pic")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Button(action: generatePDF) {
                    Text("Create PDF")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(selectedImages.isEmpty)
            }

            if let pdfDocument = pdfDocument {
                Button(action: {
                    savePDFToRealm(pdfDocument: pdfDocument, name: "My PDF Document")
                }) {
                    Text("Save PDF")
                        .font(.headline)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Button(action: { showingPDFViewer = true }) {
                    Text("Show PDF")
                        .font(.headline)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        
        NavigationLink(destination: SavedPDFsView()) {
            Text("Show saved PDFs")
                .font(.headline)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
        
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker(selectedImages: $selectedImages)
        }
        .sheet(isPresented: $showingPDFViewer) {
            if let pdfDocument = pdfDocument {
                PDFViewer(pdfDocument: pdfDocument)
            }
        }
        .alert(item: $saveSuccessMessage) { alertMessage in
            Alert(
                title: Text("Success"),
                message: Text(alertMessage.message),
                dismissButton: .default(Text("Ok")))
        }
        .navigationTitle("Create PDF")
    }

    private func generatePDF() {
        let pdf = PDFDocument()
        for (index, image) in selectedImages.enumerated() {
            if let page = PDFPage(image: image) {
                pdf.insert(page, at: index)
            }
        }
        pdfDocument = pdf
    }

    func savePDFToRealm(pdfDocument: PDFDocument, name: String) {
        guard let pdfData = pdfDocument.dataRepresentation() else {
            print("Unable to generate PDF data.")
            return
        }

        let thumbnailData: Data?
        if let firstPage = pdfDocument.page(at: 0) {
            let thumbnailSize = CGSize(width: 100, height: 100)
            let thumbnailImage = firstPage.thumbnail(of: thumbnailSize, for: .mediaBox)
            thumbnailData = thumbnailImage.pngData()
        } else {
            thumbnailData = nil
        }

        let realmPDF = RealmPDFModel()
        realmPDF.name = name
        realmPDF.pdfData = pdfData
        realmPDF.thumbnailData = thumbnailData!
        realmPDF.creationDate = Date()

        let realm = try! Realm()
        try! realm.write {
            realm.add(realmPDF)
        }

        print("PDF saved to Realm successfully!")
    }
}

