import SwiftUI

struct CartView: View {
    @Environment(CartViewModel.self) private var cart
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if cart.lines.isEmpty {
                    ContentUnavailableView("Your cart is empty", systemImage: "cart",
                                           description: Text("Add a meal to get started."))
                } else {
                    List {
                        Section {
                            ForEach(cart.lines) { line in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(line.meal.name).font(.headline)
                                        Text("Rs. \(line.meal.price * line.quantity)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    QuantityControl(
                                        quantity: line.quantity,
                                        onAdd: { cart.add(line.meal) },
                                        onRemove: { cart.remove(line.meal) }
                                    )
                                }
                            }
                        }

                        Section {
                            HStack {
                                Text("Total").font(.headline)
                                Spacer()
                                Text("Rs. \(cart.total)").font(.headline)
                            }
                            Label("Pay cash on delivery", systemImage: "banknote")
                                .foregroundStyle(.secondary)
                        }

                        Section {
                            NavigationLink("Continue to checkout") {
                                CheckoutView(onFinished: { dismiss() })
                            }
                        }
                    }
                }
            }
            .navigationTitle("Your Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
