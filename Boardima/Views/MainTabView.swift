import SwiftUI

struct MainTabView: View {
    @State private var lock = AppLockViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house") }
            ContentUnavailableView("Find Boarding", systemImage: "magnifyingglass",
                                   description: Text("Coming soon"))
                .tabItem { Label("Boardings", systemImage: "bed.double") }
            ContentUnavailableView("Meals", systemImage: "fork.knife",
                                   description: Text("Coming soon"))
                .tabItem { Label("Meals", systemImage: "fork.knife") }
            ContentUnavailableView("Saved", systemImage: "heart",
                                   description: Text("Coming soon"))
                .tabItem { Label("Saved", systemImage: "heart") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .overlay { if lock.isLocked { LockView() } }
        .environment(lock)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { lock.lockIfNeeded() }
        }
    }
}
