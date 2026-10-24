import SwiftUI

struct QuantityControl: View {
    let quantity: Int
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        if quantity == 0 {
            Button("Add", action: onAdd)
                .buttonStyle(.borderedProminent)
                .tint(Theme.orange)
                .controlSize(.small)
        } else {
            HStack(spacing: 10) {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                }
                .accessibilityLabel("Remove one")

                Text("\(quantity)")
                    .monospacedDigit()
                    .frame(minWidth: 20)

                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel("Add one")
            }
            .font(.title3)
            .foregroundStyle(Theme.navy)
            .buttonStyle(.borderless)
        }
    }
}
