import SwiftUI

struct MealRow: View {
    let meal: Meal
    @Environment(CartViewModel.self) private var cart

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name).font(.headline)
                Text(meal.vendor)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(meal.details)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text("Rs. \(meal.price)")
                    .font(.subheadline.bold())
            }
            Spacer()
            QuantityControl(
                quantity: cart.quantity(of: meal),
                onAdd: { cart.add(meal) },
                onRemove: { cart.remove(meal) }
            )
        }
        .padding(.vertical, 4)
    }
}
