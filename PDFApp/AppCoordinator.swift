import SwiftUI

protocol AppCoordinator {
    associatedtype StartView: View
    associatedtype EditPDFView: View

    func start() -> StartView
    func openEditPDF() -> EditPDFView
    func sharePdf(data: Data)
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

    private var currentScreen: UIViewController? {
        UIApplication.shared.windows.first?.rootViewController
    }
}
