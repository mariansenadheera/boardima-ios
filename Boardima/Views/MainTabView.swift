import SwiftUI

struct MainTabView: View {
    @State private var lock = AppLockViewModel()
    @State private var boardingList = BoardingListViewModel()
    @State private var saved = SavedViewModel()
    @State private var meals = MealsViewModel()
    @State private var cart = CartViewModel()
    @State private var match = MatchViewModel()
    @State private var notifications = NotificationManager()
    @State private var router = TabRouter()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $router.selected) {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppTab.home)
            BoardingListView()
                .tabItem { Label("Boardings", systemImage: "bed.double") }
                .tag(AppTab.boardings)
            MealsView()
                .tabItem { Label("Meals", systemImage: "fork.knife") }
                .badge(cart.itemCount)
                .tag(AppTab.meals)
            SavedView()
                .tabItem { Label("Saved", systemImage: "heart") }
                .tag(AppTab.saved)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(AppTab.profile)
        }
        .overlay { if lock.isLocked { LockView() } }
        .environment(lock)
        .environment(boardingList)
        .environment(saved)
        .environment(meals)
        .environment(cart)
        .environment(notifications)
        .environment(match)
        .environment(router)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { lock.lockIfNeeded() }
        }
        .task { await notifications.refreshStatus() }
    }
}
