import SwiftUI
import FirebaseCore

@main
struct BoardimaApp: App {
    @State private var authViewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        _authViewModel = State(initialValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authViewModel)
                .environment(CampusStore.shared)
        }
    }
}
