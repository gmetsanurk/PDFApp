import SwiftUI
import PDFKit

protocol AppCoordinator {
    associatedtype StartView: View
    associatedtype EditPDFView: View

    func start() -> StartView
    func openEditPDF() -> EditPDFView
    func sharePdf(data: Data)
    func showPdf(pdfDocument: PDFDocument)
}

struct UIApplicationCoordinator: AppCoordinator {
    func start() -> WelcomeView {
        WelcomeView(coordinator: self)
    }

    func openEditPDF() -> CreateEditPDFView {
        CreateEditPDFView(coordinator: self)
    }

    func sharePdf(data: Data) {
        let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        
        if let controller = currentScreen {
            controller.present(activityController, animated: true, completion: nil)
        }
    }
    
    func showPdf(pdfDocument: PDFDocument) {
        let pdfViewer = PDFViewer(pdfDocument: pdfDocument)
        
        if let controller = currentScreen {
            controller.present(UIHostingController(rootView: pdfViewer), animated: true)
        }
    }
    private var currentScreen: UIViewController? {
        UIApplication.shared.windows.first?.rootViewController
    }
}
