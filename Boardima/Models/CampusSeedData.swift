import Foundation


enum CampusSeedData {

    // Builders

    private struct BoardingSeed {
        let title: String
        let area: String
        let rent: Int
        let roomType: String
        let facilities: [String]
        let rating: Double
        let northKm: Double
        let eastKm: Double
    }

    private struct MealSeed {
        let name: String
        let vendor: String
        let price: Int
        let details: String
        let category: String
    }

    private static func b(_ title: String, _ area: String, _ rent: Int, _ roomType: String,
                          _ facilities: [String], _ rating: Double,
                          _ northKm: Double, _ eastKm: Double) -> BoardingSeed {
        BoardingSeed(title: title, area: area, rent: rent, roomType: roomType,
                     facilities: facilities, rating: rating, northKm: northKm, eastKm: eastKm)
    }

    private static func m(_ name: String, _ vendor: String, _ price: Int,
                          _ details: String, _ category: String) -> MealSeed {
        MealSeed(name: name, vendor: vendor, price: price, details: details, category: category)
    }

    private static func boardings(for campus: Campus, prefix: String, seeds: [BoardingSeed]) -> [Boarding] {
        seeds.enumerated().map { index, seed in
            let point = campus.offset(northKm: seed.northKm, eastKm: seed.eastKm)
            let km = (seed.northKm * seed.northKm + seed.eastKm * seed.eastKm).squareRoot()
            return Boarding(id: "\(prefix)-\(index + 1)", title: seed.title, address: seed.area,
                            monthlyRent: seed.rent, roomType: seed.roomType, facilities: seed.facilities,
                            rating: seed.rating, latitude: point.latitude, longitude: point.longitude,
                            distanceToUniversityKm: (km * 10).rounded() / 10)
        }
    }

    private static func meals(for campus: Campus, prefix: String,
                              vendors: [String: (north: Double, east: Double)],
                              seeds: [MealSeed]) -> [Meal] {
        seeds.enumerated().map { index, seed in
            let offset = vendors[seed.vendor] ?? (north: 0, east: 0)
            let point = campus.offset(northKm: offset.north, eastKm: offset.east)
            return Meal(id: "\(prefix)-m\(index + 1)", name: seed.name, vendor: seed.vendor,
                        price: seed.price, details: seed.details, category: seed.category,
                        vendorLatitude: point.latitude, vendorLongitude: point.longitude)
        }
    }

    // Moratuwa vendors (the original sample meals)

    static var moratuwaMeals: [Meal] {
        let offsets: [String: (north: Double, east: Double)] = [
            "Mama's Kitchen": (0.1, -0.1),
            "Night Bites": (-0.2, -0.4),
            "Campus Canteen": (0.0, 0.0),
            "Hostel Eats": (-0.5, -0.8)
        ]
        return (Meal.samples + Meal.extraSeedData).map { meal in
            let offset = offsets[meal.vendor] ?? (north: 0, east: 0)
            return meal.placed(near: .moratuwa, northKm: offset.north, eastKm: offset.east)
        }
    }

    // All other campuses

    static var boardings: [Boarding] {
        nibmBoardings + jayewardenepuraBoardings
    }

    static var meals: [Meal] {
        nibmMeals + jayewardenepuraMeals
    }

    // NIBM

    private static var nibmBoardings: [Boarding] {
        boardings(for: .nibm, prefix: "nibm", seeds: [
            b("Vidya Lodge", "Vidya Mawatha, Colombo 07", 24000, "Single", ["WiFi", "AC", "Attached bathroom"], 4.6, 0.2, 0.3),
            b("Independence Square Rooms", "Colombo 07", 28000, "Single", ["WiFi", "AC", "Laundry"], 4.4, 0.5, 0.9),
            b("Narahenpita Student Hostel", "Narahenpita", 12000, "Shared", ["WiFi", "Meals"], 4.0, -0.8, 1.6),
            b("Kirula Road Annex", "Kirula Road, Colombo 05", 17000, "Twin", ["WiFi", "Laundry"], 4.2, -1.4, 1.0),
            b("Thimbirigasyaya Boarding", "Thimbirigasyaya", 9500, "Dormitory", ["Meals", "Study room"], 3.6, -1.9, 0.5),
            b("Havelock Town Rooms", "Havelock Town", 19500, "Single", ["WiFi", "Attached bathroom"], 4.3, -2.2, 0.2),
            b("Polhengoda Shared House", "Polhengoda", 11000, "Shared", ["WiFi", "Laundry", "Study room"], 3.9, -2.8, -0.4),
            b("Bambalapitiya Twin Suites", "Bambalapitiya", 21000, "Twin", ["WiFi", "AC", "Parking"], 4.5, -3.3, -0.8)
        ])
    }

    private static var nibmMeals: [Meal] {
        meals(for: .nibm, prefix: "nibm", vendors: [
            "Vidya Cafe": (0.1, 0.2),
            "Havelock Rice House": (-0.5, 0.3),
            "Narahenpita Bites": (-0.9, 1.2),
            "Kirula Kitchen": (-1.3, 0.9)
        ], seeds: [
            m("String Hoppers & Sambol", "Vidya Cafe", 280, "Eight string hoppers with pol sambol and dhal.", "Breakfast"),
            m("Egg Sandwich & Tea", "Vidya Cafe", 250, "Toasted egg sandwich with milk tea.", "Breakfast"),
            m("Chicken Rice & Curry", "Havelock Rice House", 520, "Rice with chicken curry, dhal and two vegetables.", "Lunch"),
            m("Veg Rice & Curry", "Havelock Rice House", 380, "Rice with four vegetable curries and papadam.", "Lunch"),
            m("Chicken Kottu", "Narahenpita Bites", 650, "Chicken kottu with cheese on request.", "Dinner"),
            m("Seafood Fried Rice", "Narahenpita Bites", 720, "Fried rice with prawns and cuttlefish.", "Dinner"),
            m("Submarine Roll", "Kirula Kitchen", 320, "Loaded submarine roll with chicken filling.", "Snacks"),
            m("Fish Cutlets (3)", "Kirula Kitchen", 210, "Three crispy fish cutlets with chilli sauce.", "Snacks")
        ])
    }

    // Sri Jayewardenepura

    private static var jayewardenepuraBoardings: [Boarding] {
        boardings(for: .jayewardenepura, prefix: "sjp", seeds: [
            b("Gangodawila Gardens", "Gangodawila, Nugegoda", 11500, "Shared", ["WiFi", "Meals"], 4.1, 0.2, -0.3),
            b("Scholars Inn", "Gangodawila", 18500, "Single", ["WiFi", "AC", "Study room"], 4.6, -0.3, 0.4),
            b("Nugegoda Town Rooms", "Nugegoda", 13500, "Twin", ["WiFi", "Laundry"], 4.0, -0.9, -0.6),
            b("Pagoda Road Hostel", "Pagoda", 8000, "Dormitory", ["Meals", "WiFi"], 3.5, 0.9, 0.3),
            b("Delkanda Student House", "Delkanda", 10000, "Shared", ["WiFi", "Laundry"], 3.8, -1.6, 0.2),
            b("Nawala Road Annex", "Nawala", 21000, "Single", ["WiFi", "AC", "Attached bathroom", "Parking"], 4.7, 1.8, 0.4),
            b("Maharagama Budget Stay", "Maharagama", 7500, "Dormitory", ["Meals"], 3.4, -2.5, 1.2),
            b("Kotte Lane Twin Rooms", "Kotte", 15500, "Twin", ["WiFi", "Study room"], 4.2, 1.4, -1.0)
        ])
    }

    private static var jayewardenepuraMeals: [Meal] {
        meals(for: .jayewardenepura, prefix: "sjp", vendors: [
            "Gangodawila Kitchen": (0.1, -0.2),
            "Uni Canteen": (0.0, 0.1),
            "Nugegoda Bites": (-0.8, -0.5),
            "Pagoda Eats": (0.8, 0.4)
        ], seeds: [
            m("Egg Hoppers (3)", "Gangodawila Kitchen", 300, "Three egg hoppers with lunu miris.", "Breakfast"),
            m("Kiribath & Lunu Miris", "Uni Canteen", 220, "Milk rice with spicy onion sambol.", "Breakfast"),
            m("Rice & Curry (Fish)", "Gangodawila Kitchen", 430, "Rice with fish curry, dhal and a vegetable.", "Lunch"),
            m("Rice & Curry (Veg)", "Uni Canteen", 330, "Rice with three vegetable curries.", "Lunch"),
            m("Devilled Chicken Rice", "Nugegoda Bites", 620, "Fried rice with devilled chicken.", "Dinner"),
            m("Egg Kottu", "Nugegoda Bites", 560, "Egg kottu, medium spice.", "Dinner"),
            m("Vegetable Roll (2)", "Pagoda Eats", 160, "Two crispy vegetable rolls.", "Snacks"),
            m("Milk Tea & Short Eats", "Pagoda Eats", 190, "Milk tea with two short eats.", "Snacks")
        ])
    }
}
