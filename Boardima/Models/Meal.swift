import Foundation

struct Meal: Identifiable, Hashable {
    let id: String
    var name: String
    var vendor: String
    var price: Int
    var details: String
    var category: String

    static let samples: [Meal] = [
        Meal(id: "m1", name: "Rice & Curry (Veg)", vendor: "Mama's Kitchen", price: 350,
             details: "Rice with three vegetable curries and sambol.", category: "Lunch"),
        Meal(id: "m2", name: "Egg Kottu", vendor: "Night Bites", price: 600,
             details: "Classic egg kottu, medium spice.", category: "Dinner")
    ]
}
