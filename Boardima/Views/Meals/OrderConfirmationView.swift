import SwiftUI

struct OrderConfirmationView: View {
    @Environment(CartViewModel.self) private var cart
    let order: Order
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            Text("Order placed!")
                .font(.title.bold())

            Text("Please have Rs. \(order.total) ready in cash when your meal arrives.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(order.lines) { line in
                    Text("\(line.quantity) × \(line.meal.name)")
                }
                Divider()
                Text("Delivering to: \(order.deliveryAddress)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))

            Button("Done", action: onDone)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .onDisappear { cart.clear() }
    }
}
