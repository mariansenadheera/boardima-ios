import SwiftUI

struct MainTabView: View {
    @State private var lock = AppLockViewModel()
    @State private var boardingList = BoardingListViewModel()
    @State private var saved = SavedViewModel()
    @State private var meals = MealsViewModel()
    @State private var cart = CartViewModel()
    @State private var match = MatchViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house") }
            BoardingListView()
                .tabItem { Label("Boardings", systemImage: "bed.double") }
            MealsView()
                .tabItem { Label("Meals", systemImage: "fork.knife") }
                .badge(cart.itemCount)
            SavedView()
                .tabItem { Label("Saved", systemImage: "heart") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .overlay { if lock.isLocked { LockView() } }
        .environment(lock)
        .environment(boardingList)
        .environment(saved)
        .environment(meals)
        .environment(cart)
        .environment(match)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { lock.lockIfNeeded() }
        }
    }
}
