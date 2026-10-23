import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(AuthViewModel.self) private var auth

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView { hasSeenOnboarding = true }
        } else if auth.isAuthenticated {
            MainTabView()
        } else {
            AuthView()
        }
    }
}

#Preview {
    RootView()
        .environment(AuthViewModel(service: PreviewAuthService()))
}
