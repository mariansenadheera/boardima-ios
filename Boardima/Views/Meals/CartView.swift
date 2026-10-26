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
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(cart.lines) { line in
                                HStack(spacing: 12) {
                                    PhotoView(name: PhotoLibrary.foodImageName(for: line.meal.id),
                                              symbol: "fork.knife")
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(line.meal.name).font(.headline)
                                        Text(line.meal.vendor)
                                            .font(.caption)
                                            .foregroundStyle(Theme.brown)
                                        Text("Rs. \(line.meal.price * line.quantity)")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(Theme.orangeStrong)
                                    }
                                    Spacer(minLength: 4)
                                    QuantityControl(
                                        quantity: line.quantity,
                                        itemName: line.meal.name,
                                        onAdd: { cart.add(line.meal) },
                                        onRemove: { cart.remove(line.meal) }
                                    )
                                }
                                .padding(12)
                                .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                            }

                            VStack(spacing: 10) {
                                HStack {
                                    Text("Total amount").font(.headline)
                                    Spacer()
                                    Text("Rs. \(cart.total)")
                                        .font(.title2.bold())
                                        .foregroundStyle(Theme.navy)
                                }
                                Divider()
                                HStack {
                                    Label("Cash on delivery", systemImage: "banknote")
                                    Spacer()
                                    Text("No upfront payment")
                                        .foregroundStyle(Theme.brown)
                                }
                                .font(.footnote)
                            }
                            .cardStyle()

                            NavigationLink {
                                CheckoutView(onFinished: { dismiss() })
                            } label: {
                                Text("Continue to checkout")
                            }
                            .buttonStyle(BrandButtonStyle())
                        }
                        .readableContentWidth(640)
                        .padding()
                    }
                }
            }
            .background(Theme.background)
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
