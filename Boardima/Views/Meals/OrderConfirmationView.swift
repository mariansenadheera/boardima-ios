import SwiftUI

struct OrderConfirmationView: View {
    @Environment(CartViewModel.self) private var cart
    let order: Order
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 96, height: 96)
                    .background(Theme.navy, in: Circle())
                    .shadow(color: Theme.orange.opacity(0.3), radius: 16)
                    .padding(.top, 24)
                    .accessibilityHidden(true)

                VStack(spacing: 6) {
                    Text("Order placed!").font(.title.bold())
                    Text("We'll send you a notification as your order is prepared and on its way.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Delivering to", systemImage: "mappin.and.ellipse")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(order.deliveryAddress).font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()

                VStack(alignment: .leading, spacing: 10) {
                    Label("Order summary", systemImage: "fork.knife")
                        .font(.headline)
                    Divider()
                    ForEach(order.lines) { line in
                        HStack {
                            Text("\(line.quantity) × \(line.meal.name)")
                            Spacer()
                            Text("Rs. \(line.meal.price * line.quantity)")
                        }
                        .font(.subheadline)
                    }

                    VStack(spacing: 6) {
                        HStack {
                            Text("Total amount").foregroundStyle(.secondary)
                            Spacer()
                            Text("Rs. \(order.total)")
                                .font(.title2.bold())
                                .foregroundStyle(Theme.navy)
                        }
                        Divider()
                        HStack {
                            Text("Payment: Cash on delivery").font(.footnote)
                            Spacer()
                            Text("No upfront payment")
                                .font(.footnote)
                                .foregroundStyle(Theme.brown)
                        }
                    }
                    .padding(12)
                    .background(Theme.navy.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
                }
                .cardStyle()

                Button("Done", action: onDone)
                    .buttonStyle(BrandButtonStyle())
            }
            .padding()
        }
        .background(Theme.background)
        .navigationBarBackButtonHidden(true)
        .onDisappear { cart.clear() }
    }
}
