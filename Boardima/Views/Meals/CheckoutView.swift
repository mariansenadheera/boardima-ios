import SwiftUI

struct CheckoutView: View {
    @Environment(CartViewModel.self) private var cart
    @Environment(NotificationManager.self) private var notifications
    let onFinished: () -> Void

    @State private var address = ""
    @State private var phone = ""
    @State private var note = ""
    @State private var placedOrder: Order?

    var body: some View {
        if let order = placedOrder {
            OrderConfirmationView(order: order, onDone: onFinished)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Delivery destination")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)

                    VStack(spacing: 0) {
                        FormFieldRow(icon: "mappin.and.ellipse", title: "BOARDING ADDRESS") {
                            TextField("Where should we deliver?", text: $address, axis: .vertical)
                                .textContentType(.fullStreetAddress)
                        }
                        Divider()
                        FormFieldRow(icon: "phone", title: "PHONE NUMBER") {
                            TextField("07X XXX XXXX", text: $phone)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                        }
                        Divider()
                        FormFieldRow(icon: "text.bubble", title: "NOTE FOR THE VENDOR (OPTIONAL)") {
                            TextField("Less spicy, no onions…", text: $note, axis: .vertical)
                        }
                    }
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Order summary", systemImage: "fork.knife")
                            .font(.headline)
                        Divider()
                        ForEach(cart.lines) { line in
                            HStack {
                                Text("\(line.quantity) × \(line.meal.name)")
                                Spacer()
                                Text("Rs. \(line.meal.price * line.quantity)")
                            }
                            .font(.subheadline)
                        }
                        HStack {
                            Text("Total amount").font(.headline)
                            Spacer()
                            Text("Rs. \(cart.total)")
                                .font(.title3.bold())
                                .foregroundStyle(Theme.navy)
                        }
                        .padding(.top, 4)
                        HStack {
                            Label("Payment: Cash on delivery", systemImage: "banknote")
                            Spacer()
                            Text("No upfront payment").foregroundStyle(Theme.brown)
                        }
                        .font(.footnote)
                    }
                    .cardStyle()

                    if let message = cart.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task {
                            if let order = await cart.placeOrder(address: address, phone: phone, note: note) {
                                placedOrder = order
                                await notifications.scheduleOrderUpdates(for: order)
                            }
                        }
                    } label: {
                        if cart.isPlacing {
                            ProgressView().tint(.white)
                        } else {
                            Label("Confirm order", systemImage: "checkmark.circle")
                        }
                    }
                    .buttonStyle(BrandButtonStyle(tint: Theme.orange))
                    .disabled(cart.isPlacing)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background)
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
