import SwiftUI

struct MealRow: View {
    let meal: Meal
    @Environment(CartViewModel.self) private var cart
    @Environment(CampusStore.self) private var campusStore

    var body: some View {
        HStack(spacing: 12) {
            PhotoView(name: PhotoLibrary.foodImageName(for: meal.id), symbol: "fork.knife")
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    AvatarView(imageName: "avatar-vendor", initials: "V", size: 20)
                    Text(meal.vendor)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.brown)
                        .lineLimit(1)
                }
                Text(meal.name).font(.headline)
                Text("\(meal.distance(from: campusStore.selected), specifier: "%.1f") km away")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Rs. \(meal.price)")
                    .font(.subheadline.bold())
                    .foregroundStyle(Theme.orange)
            }
            Spacer(minLength: 4)
            QuantityControl(
                quantity: cart.quantity(of: meal),
                onAdd: { cart.add(meal) },
                onRemove: { cart.remove(meal) }
            )
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}
