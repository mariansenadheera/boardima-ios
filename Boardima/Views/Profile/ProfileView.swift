import SwiftUI

struct ProfileView: View {
    @Environment(AppLockViewModel.self) private var lock

    var body: some View {
        NavigationStack {
            Form {
                Section("Security") {
                    Toggle("Unlock with \(lock.biometryName)", isOn: Binding(
                        get: { lock.isFaceIDEnabled },
                        set: { newValue in Task { await lock.setEnabled(newValue) } }
                    ))
                    .disabled(!lock.isBiometryAvailable)

                    if !lock.isBiometryAvailable {
                        Text("Biometrics are not available or not set up on this device.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
