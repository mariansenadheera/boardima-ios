import SwiftUI

struct ProfileView: View {
    @Environment(AppLockViewModel.self) private var lock
    @Environment(MatchViewModel.self) private var match

    var body: some View {
        @Bindable var match = match

        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading) {
                        Text("Monthly budget: Rs. \(Int(match.budget))")
                        Slider(value: $match.budget, in: 5000...40000, step: 500)
                            .accessibilityLabel("Monthly budget")
                    }
                    Picker("Preferred room type", selection: $match.preferredRoomType) {
                        ForEach(MatchViewModel.roomTypes, id: \.self) { Text($0).tag($0) }
                    }
                } header: {
                    Text("Match preferences")
                } footer: {
                    Text(match.isModelAvailable
                         ? "Boardima scores each boarding for you with an on-device Core ML model."
                         : "The Core ML model isn't in the app yet.")
                }

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
