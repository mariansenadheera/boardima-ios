import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            Theme.navy.ignoresSafeArea()
            VStack(spacing: 14) {
                LogoMark(size: 120)
                Text("Boardima")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                Text("Student boardings and meals")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .scaleEffect(appeared || reduceMotion ? 1 : 0.85)
            .opacity(appeared || reduceMotion ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Boardima")
    }
}
