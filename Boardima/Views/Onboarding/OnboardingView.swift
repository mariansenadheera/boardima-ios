import SwiftUI

private struct OnboardingPage: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let message: String
}

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages = [
        OnboardingPage(id: 0, icon: "house.lodge.fill",
                       title: "Find a boarding near campus",
                       message: "Search, filter and compare student boardings, see them on a map and get directions."),
        OnboardingPage(id: 1, icon: "fork.knife",
                       title: "Affordable meals",
                       message: "Order cheap, tasty meals from local vendors and pay cash on delivery."),
        OnboardingPage(id: 2, icon: "sparkles",
                       title: "Matched to you",
                       message: "Boardima scores every boarding against your budget and preferences, right on your device."),
        OnboardingPage(id: 3, icon: "lock.shield.fill",
                       title: "Safe and simple",
                       message: "Lock the app with Face ID and get notified about your orders.")
    ]

    private var isLastPage: Bool { page == pages.count - 1 }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                if !isLastPage {
                    Button("Skip", action: onFinish)
                        .padding()
                }
            }
            .frame(height: 44)

            TabView(selection: $page) {
                ForEach(pages) { item in
                    VStack(spacing: 20) {
                        Image(systemName: item.icon)
                            .font(.system(size: 80))
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                        Text(item.title)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                        Text(item.message)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if isLastPage {
                    onFinish()
                } else {
                    if reduceMotion { page += 1 } else { withAnimation { page += 1 } }
                }
            } label: {
                Text(isLastPage ? "Get started" : "Next")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }
}

#Preview { OnboardingView(onFinish: {}) }
