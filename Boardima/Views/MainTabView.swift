import SwiftUI

struct MainTabView: View {
    @State private var lock = AppLockViewModel()
    @State private var boardingList = BoardingListViewModel()
    @State private var saved = SavedViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house") }
            BoardingListView()
                .tabItem { Label("Boardings", systemImage: "bed.double") }
            ContentUnavailableView("Meals", systemImage: "fork.knife",
                                   description: Text("Coming soon"))
                .tabItem { Label("Meals", systemImage: "fork.knife") }
            SavedView()
                .tabItem { Label("Saved", systemImage: "heart") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .overlay { if lock.isLocked { LockView() } }
        .environment(lock)
        .environment(boardingList)
        .environment(saved)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { lock.lockIfNeeded() }
        }
    }
}
