import SwiftUI

struct LockView: View {
    @Environment(AppLockViewModel.self) private var lock

    var body: some View {
        ZStack {
            Rectangle().fill(.background).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .accessibilityHidden(true)
                Text("Boardima is locked")
                    .font(.title2.bold())
                Button("Unlock with \(lock.biometryName)") {
                    Task { await lock.unlock() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .task { await lock.unlock() }
    }
}
