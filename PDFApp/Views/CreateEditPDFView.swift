import SwiftUI
import PDFKit

struct CreateEditPDFView: View {
    @StateObject private var viewModel = CreateEditPDFViewModel()
    private var coordinator: any AppCoordinator

    init(coordinator: any AppCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        VStack {
            if viewModel.selectedImages.isEmpty {
                Text("Choose pic for editing PDF")
                    .foregroundColor(AppColors.textSecondary)
                    .padding()
            } else {
                ScrollView {
                    VStack {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
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
                Button(action: { viewModel.onButtonAddPicPressed() }) {
                    Text("Add pic")
                        .font(.headline)
                        .padding()
                        .background(AppColors.buttonPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(AppGeometry.cornerRadius)
                }
                .padding()
                
                Button(action: { viewModel.generatePDF() }) {
                    Text("Create PDF")
                        .font(.headline)
                        .padding()
                        .background(AppColors.buttonPrimary)
                        .foregroundColor(AppColors.textPrimary)
                        .cornerRadius(AppGeometry.cornerRadius)
                }
                .padding()
                .disabled(viewModel.selectedImages.isEmpty)
            }
            
            if let pdfDocument = viewModel.pdfDocument {
                Button(action: {
                    viewModel.savePDFToRealm(pdfDocument: pdfDocument, name: "My PDF Document")
                }) {
                    Text("Save PDF")
                        .font(.headline)
                        .padding()
                        .background(AppColors.buttonSecondary)
                        .foregroundColor(AppColors.textPrimary)
                        .cornerRadius(AppGeometry.cornerRadius)
                }
                .padding()
                
                Button(action: { viewModel.onShowPdfPressed() }) {
                    Text("Show PDF")
                        .font(.headline)
                        .padding()
                        .background(AppColors.buttonSecondary)
                        .foregroundColor(AppColors.textPrimary)
                        .cornerRadius(AppGeometry.cornerRadius)
                }
                .padding()
            }
        }
        
        NavigationLink(destination: SavedPDFsView(coordinator: coordinator)) {
            Text("Show saved PDFs")
                .font(.headline)
                .padding()
                .background(AppColors.showSavedPDFs)
                .foregroundColor(AppColors.textPrimary)
                .cornerRadius(AppGeometry.cornerRadius)
        }
        .padding()
        
        .sheet(isPresented: $viewModel.showingPhotoPicker) {
            PhotoPicker(selectedImages: $viewModel.selectedImages)
        }
        .sheet(isPresented: $viewModel.showingPDFViewer) {
            if let pdfDocument = viewModel.pdfDocument {
                PDFViewer(pdfDocument: pdfDocument)
            }
        }
        .alert(item: $viewModel.saveSuccessMessage) { alertMessage in
            Alert(
                title: Text("Success"),
                message: Text(alertMessage.message),
                dismissButton: .default(Text("Ok"))
            )
        }
        .navigationTitle("Create PDF")
    }
}

