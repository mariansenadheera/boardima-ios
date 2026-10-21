import SwiftUI

struct CheckoutView: View {
    @Environment(CartViewModel.self) private var cart
    let onFinished: () -> Void

    @State private var address = ""
    @State private var phone = ""
    @State private var note = ""
    @State private var placedOrder: Order?

    var body: some View {
        if let order = placedOrder {
            OrderConfirmationView(order: order, onDone: onFinished)
        } else {
            Form {
                Section("Delivery details") {
                    TextField("Boarding address", text: $address, axis: .vertical)
                        .textContentType(.fullStreetAddress)
                    TextField("Phone number", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Note for the vendor (optional)", text: $note, axis: .vertical)
                }

                Section("Payment") {
                    Label("Cash on delivery", systemImage: "banknote")
                    Text("You pay the delivery person in cash when your meal arrives.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Summary") {
                    ForEach(cart.lines) { line in
                        HStack {
                            Text("\(line.quantity) × \(line.meal.name)")
                            Spacer()
                            Text("Rs. \(line.meal.price * line.quantity)")
                        }
                        .font(.subheadline)
                    }
                    HStack {
                        Text("Total").bold()
                        Spacer()
                        Text("Rs. \(cart.total)").bold()
                    }
                }

                if let message = cart.errorMessage {
                    Section {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task {
                            placedOrder = await cart.placeOrder(address: address, phone: phone, note: note)
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if cart.isPlacing {
                                ProgressView()
                            } else {
                                Text("Place order").bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(cart.isPlacing)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
