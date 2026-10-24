import SwiftUI

struct MealCard: View {
    let meal: Meal
    @Environment(CartViewModel.self) private var cart
    @Environment(CampusStore.self) private var campusStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PhotoView(name: PhotoLibrary.foodImageName(for: meal.id), symbol: "fork.knife")
                .frame(height: 120)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    AvatarView(imageName: "avatar-vendor", initials: "V", size: 20)
                    Text(meal.vendor)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.brown)
                        .lineLimit(1)
                }
                Text(meal.name)
                    .font(.headline)
                    .lineLimit(2, reservesSpace: true)
                Label("\(meal.distance(from: campusStore.selected), specifier: "%.1f") km away",
                      systemImage: "location")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Text("Rs. \(meal.price)")
                        .font(.headline)
                        .foregroundStyle(Theme.orange)
                    Spacer()
                    Button("Order Now") { cart.add(meal) }
                        .font(.footnote.bold())
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.orange)
                }
            }
            .padding(12)
        }
        .frame(width: 240)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}
