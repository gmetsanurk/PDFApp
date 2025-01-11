import SwiftUI
import RealmSwift

@main
struct PDFApp: SwiftUI.App {
    let coordinator = UIApplicationCoordinator()

    init() {
        setupRealm()
    }
    
    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
    
    private func setupRealm() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }
}
