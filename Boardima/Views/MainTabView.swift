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
    @State private var openedBoarding: Boarding?
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
        //adaptive layout
        .adaptiveTabStyle()
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
            if phase == .active { applyPendingTab() }
        }
        .onOpenURL { url in
            guard let id = PosterLink.boardingID(from: url.absoluteString) else { return }
            Task {
                await boardingList.load()
                openedBoarding = boardingList.boardings.first { $0.id == id }
            }
        }
        .sheet(item: $openedBoarding) { boarding in
            NavigationStack {
                BoardingDetailView(boarding: boarding)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { openedBoarding = nil }
                        }
                    }
            }
        }
        .task {
            await notifications.refreshStatus()
            applyPendingTab()
            await boardingList.load()
            publishWidget()
        }
        .onChange(of: saved.savedIDs) { _, _ in publishWidget() }
        .onChange(of: CampusStore.shared.selected) { _, _ in publishWidget() }
    }
    
    private func applyPendingTab() {
        if let tab = PendingNavigation.take() { router.selected = tab }
    }

    private func publishWidget() {
        WidgetPublisher.publish(list: boardingList, match: match, saved: saved,
                                campus: CampusStore.shared.selected)
    }
}
