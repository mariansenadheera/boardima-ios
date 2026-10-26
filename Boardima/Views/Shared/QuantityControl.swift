import SwiftUI

struct QuantityControl: View {
    let quantity: Int
    var itemName: String = ""
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        if quantity == 0 {
            Button("Add", action: onAdd)
                .buttonStyle(.borderedProminent)
                .tint(Theme.orangeStrong)
                .controlSize(.small)
                .accessibilityLabel("Add \(itemName) to cart")
        } else {
            HStack(spacing: 10) {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                }
                .accessibilityLabel("Remove one \(itemName)")

                Text("\(quantity)")
                    .monospacedDigit()
                    .frame(minWidth: 20)
                    .accessibilityLabel("\(quantity) in cart")

                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel("Add one \(itemName)")
            }
            .font(.title3)
            .foregroundStyle(Theme.navy)
            .buttonStyle(.borderless)
        }
    }
}
