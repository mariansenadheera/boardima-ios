import SwiftUI

struct ProfileView: View {
    @Environment(AppLockViewModel.self) private var lock
    @Environment(MatchViewModel.self) private var match
    @Environment(NotificationManager.self) private var notifications
    @Environment(AuthViewModel.self) private var auth
    @Environment(CampusStore.self) private var campusStore
    @State private var seedMessage: String?
    @AppStorage("appearance") private var appearance = AppearanceMode.system.rawValue
    
    private var initials: String {
        let letters = auth.fullName.split(separator: " ").prefix(2).compactMap(\.first)
        return letters.isEmpty ? "S" : String(letters).uppercased()
    }

    var body: some View {
        @Bindable var match = match
        @Bindable var store = campusStore

        NavigationStack {
                    VStack(spacing: 0) {
                        AppHeader()
                        Text("Profile")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                            .accessibilityAddTraits(.isHeader)
                        Form {
                Section {
                    HStack(spacing: 16) {
                        AvatarView(imageName: "avatar-user", initials: initials, size: 60)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(auth.fullName.isEmpty ? "Student" : auth.fullName)
                                .font(.headline)
                            Text(auth.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                }
                Section("Campus") {
                    Picker("Heading to", selection: $store.selected) {
                        ForEach(Campus.all) { campus in
                            Text(campus.name).tag(campus)
                        }
                    }
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("App theme")
                }
                            
                
                Section("Account") {
                    Button("Sign out", role: .destructive) { auth.signOut() }
                }
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
                
                Section {
                    Toggle("Daily boarding reminder (6 pm)", isOn: Binding(
                        get: { notifications.remindersEnabled },
                        set: { newValue in Task { await notifications.setRemindersEnabled(newValue) } }
                    ))
                    Button("Send a test notification") {
                        Task { await notifications.sendTestNotification() }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text(notifications.isAuthorized
                         ? "Order updates and reminders will appear as notifications."
                         : "Allow notifications when asked, or turn them on in Settings > Boardima.")
                }
                
                Section("Machine learning") {
                    NavigationLink("Core ML model demo") {
                        CoreMLDemoView()
                    }
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
#if DEBUG
                Section {
                    Button("Upload sample data to Firestore") {
                        Task {
                            do {
                                try await FirestoreSeeder().seed()
                                seedMessage = "Uploaded. Pull down on the Boardings and Meals lists to refresh."
                            } catch {
                                seedMessage = "Upload failed: \(error.localizedDescription)"
                            }
                        }
                    }
                    if let seedMessage {
                        Text(seedMessage).font(.footnote).foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Developer")
                }
#endif
            }
                    }
                                .background(Theme.background)
                                .toolbar(.hidden, for: .navigationBar)
        }
    }
}
