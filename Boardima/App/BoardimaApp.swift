import SwiftUI
import FirebaseCore

@main
struct BoardimaApp: App {
    @State private var authViewModel: AuthViewModel
    @State private var showSplash = !ProcessInfo.processInfo.arguments.contains("-skipSplash")
    @AppStorage("appearance") private var appearance = AppearanceMode.system.rawValue

    init() {
        FirebaseApp.configure()
        _authViewModel = State(initialValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environment(authViewModel)
                    .environment(CampusStore.shared)
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(AppearanceMode(rawValue: appearance)?.scheme)
            .task {
                guard showSplash else { return }
                try? await Task.sleep(for: .seconds(1.4))
                withAnimation(.easeOut(duration: 0.4)) { showSplash = false }
            }
        }
    }
}
