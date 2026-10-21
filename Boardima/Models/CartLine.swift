import Foundation

struct CartLine: Identifiable, Hashable {
    let meal: Meal
    var quantity: Int

    var id: String { meal.id }
}
