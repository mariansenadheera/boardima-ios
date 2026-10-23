import Foundation

struct Meal: Identifiable, Hashable {
    let id: String
    var name: String
    var vendor: String
    var price: Int
    var details: String
    var category: String
    var vendorLatitude: Double = Campus.moratuwa.latitude
    var vendorLongitude: Double = Campus.moratuwa.longitude

    static let samples: [Meal] = [
        Meal(id: "m1", name: "String Hoppers & Dhal", vendor: "Mama's Kitchen", price: 250,
             details: "Ten string hoppers with dhal curry and coconut sambol.", category: "Breakfast"),
        Meal(id: "m2", name: "Rice & Curry (Veg)", vendor: "Mama's Kitchen", price: 350,
             details: "Rice with three vegetable curries and sambol.", category: "Lunch"),
        Meal(id: "m3", name: "Chicken Rice & Curry", vendor: "Mama's Kitchen", price: 480,
             details: "Rice with chicken curry, dhal and two vegetables.", category: "Lunch"),
        Meal(id: "m4", name: "Egg Kottu", vendor: "Night Bites", price: 600,
             details: "Classic egg kottu, medium spice.", category: "Dinner"),
        Meal(id: "m5", name: "Fried Rice (Egg)", vendor: "Night Bites", price: 520,
             details: "Egg fried rice with devilled gravy on the side.", category: "Dinner"),
        Meal(id: "m6", name: "Egg Roll (2 pcs)", vendor: "Campus Canteen", price: 180,
             details: "Crispy egg rolls with chilli sauce.", category: "Snacks")
    ]
}
