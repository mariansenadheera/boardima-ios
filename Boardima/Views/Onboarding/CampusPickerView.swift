import SwiftUI

struct CampusPickerView: View {
    @Environment(CampusStore.self) private var store
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
                .padding(.top, 40)
                .accessibilityHidden(true)

            Text("Which campus are you heading to?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("We'll show boardings and food near it. You can change this any time.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            List(Campus.all) { campus in
                Button {
                    store.selected = campus
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(campus.name).font(.headline)
                            Text(campus.area)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if store.selected == campus {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.tint)
                                .accessibilityLabel("Selected")
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .listStyle(.insetGrouped)

            Button(action: onDone) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    CampusPickerView(onDone: {})
        .environment(CampusStore.shared)
}
