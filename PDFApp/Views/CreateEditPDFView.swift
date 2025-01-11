import SwiftUI
import PDFKit

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct CreateEditPDFView: View {
    @StateObject private var viewModel = CreateEditPDFViewModel()
    @State private var showingPhotoPicker = false
    @State private var showingPDFViewer = false
    
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
                Button(action: { showingPhotoPicker = true }) {
                    Text("Add pic")
                        .font(.headline)
                        .padding()
                        .background(AppColors.buttonPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: { viewModel.generatePDF() }) {
                    Text("Create PDF")
                        .font(.headline)
                        .padding()
                        .background(AppColors.buttonPrimary)
                        .foregroundColor(AppColors.textPrimary)
                        .cornerRadius(10)
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
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: { showingPDFViewer = true }) {
                    Text("Show PDF")
                        .font(.headline)
                        .padding()
                        .background(AppColors.buttonSecondary)
                        .foregroundColor(AppColors.textPrimary)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        
        NavigationLink(destination: SavedPDFsView()) {
            Text("Show saved PDFs")
                .font(.headline)
                .padding()
                .background(AppColors.showSavedPDFs)
                .foregroundColor(AppColors.textPrimary)
                .cornerRadius(10)
        }
        .padding()
        
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker(selectedImages: $viewModel.selectedImages)
        }
        .sheet(isPresented: $showingPDFViewer) {
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
