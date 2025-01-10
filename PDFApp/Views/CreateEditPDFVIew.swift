import SwiftUI
import PDFKit
import PhotosUI
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

            if let _ = pdfDocument {
                Button(action: savePDFToRealm) {
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

    private func savePDFToRealm() {
        guard let pdfDocument = pdfDocument else { return }

        guard let data = pdfDocument.dataRepresentation() else {
            saveSuccessMessage = AlertMessage(message: "Cannot save PDF.")
            return
        }

        let realm = try! Realm()

        let pdfModel = RealmPDFModel()
        pdfModel.name = "Document \(Date())"
        pdfModel.dateCreated = Date()
        pdfModel.pdfData = data

        do {
            try realm.write {
                realm.add(pdfModel)
            }
            saveSuccessMessage = AlertMessage(message: "PDF successfully saved to DB")
        } catch {
            saveSuccessMessage = AlertMessage(message: "Error while saving PDF: \(error.localizedDescription)")
        }
    }
}

