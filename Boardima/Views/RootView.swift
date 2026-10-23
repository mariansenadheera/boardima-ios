import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasChosenCampus") private var hasChosenCampus = false
    @Environment(AuthViewModel.self) private var auth

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView { hasSeenOnboarding = true }
        } else if !auth.isAuthenticated {
            AuthView()
        } else if !hasChosenCampus {
            CampusPickerView { hasChosenCampus = true }
        } else {
            MainTabView()
        }
    }
}

#Preview {
    RootView()
        .environment(AuthViewModel(service: PreviewAuthService()))
        .environment(CampusStore.shared)
}
