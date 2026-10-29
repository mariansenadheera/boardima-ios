import Foundation

extension Boarding {
    
    static let extraSeedData: [Boarding] = [
        Boarding(id: "7", title: "Sunrise Annex", address: "Katubedda Road, Moratuwa",
                 monthlyRent: 14000, roomType: "Single", facilities: ["WiFi", "Study room"],
                 rating: 4.1, latitude: 6.7985, longitude: 79.8975, distanceToUniversityKm: 0.5),
        Boarding(id: "8", title: "Orchid Hostel", address: "Rawatawatta Road, Moratuwa",
                 monthlyRent: 8500, roomType: "Dormitory", facilities: ["WiFi", "Meals"],
                 rating: 3.7, latitude: 6.7870, longitude: 79.8890, distanceToUniversityKm: 1.6),
        Boarding(id: "9", title: "Palm Grove Rooms", address: "Egodauyana, Moratuwa",
                 monthlyRent: 11000, roomType: "Shared", facilities: ["WiFi", "Laundry"],
                 rating: 4.0, latitude: 6.7800, longitude: 79.8950, distanceToUniversityKm: 1.8),
        Boarding(id: "10", title: "Lotus Residence", address: "Piliyandala Road, Katubedda",
                 monthlyRent: 19500, roomType: "Single", facilities: ["WiFi", "AC", "Attached bathroom"],
                 rating: 4.7, latitude: 6.7930, longitude: 79.9040, distanceToUniversityKm: 0.5),
        Boarding(id: "11", title: "Student Haven", address: "Koralawella, Moratuwa",
                 monthlyRent: 10500, roomType: "Shared", facilities: ["Meals", "Study room", "Laundry"],
                 rating: 3.8, latitude: 6.7820, longitude: 79.8850, distanceToUniversityKm: 2.3),
        Boarding(id: "12", title: "Maple Twin Rooms", address: "Moratuwa Town",
                 monthlyRent: 16000, roomType: "Twin", facilities: ["WiFi", "Laundry"],
                 rating: 4.4, latitude: 6.7765, longitude: 79.8845, distanceToUniversityKm: 2.7),
        Boarding(id: "13", title: "Greenfield Boarding", address: "Katubedda Junction",
                 monthlyRent: 13000, roomType: "Shared", facilities: ["WiFi", "Meals"],
                 rating: 4.3, latitude: 6.7940, longitude: 79.8985, distanceToUniversityKm: 0.3),
        Boarding(id: "14", title: "Quiet Corner Annex", address: "Uyana Road, Katubedda",
                 monthlyRent: 20500, roomType: "Single", facilities: ["WiFi", "AC", "Parking"],
                 rating: 4.5, latitude: 6.8010, longitude: 79.9060, distanceToUniversityKm: 0.9),
        Boarding(id: "15", title: "Budget Stay", address: "Rawatawatta, Moratuwa",
                 monthlyRent: 6500, roomType: "Dormitory", facilities: ["Meals"],
                 rating: 3.4, latitude: 6.7845, longitude: 79.8835, distanceToUniversityKm: 2.2)
    ]
}

extension Meal {
    static let extraSeedData: [Meal] = [
        Meal(id: "m7", name: "Egg Hoppers (3)", vendor: "Mama's Kitchen", price: 300,
             details: "Three egg hoppers with lunu miris.", category: "Breakfast"),
        Meal(id: "m8", name: "Pol Roti & Sambol", vendor: "Hostel Eats", price: 200,
             details: "Four pol rotis with katta sambol.", category: "Breakfast"),
        Meal(id: "m9", name: "Fish Curry Rice", vendor: "Mama's Kitchen", price: 420,
             details: "Rice with fish curry, dhal and a vegetable.", category: "Lunch"),
        Meal(id: "m10", name: "Dhal & Rice Packet", vendor: "Hostel Eats", price: 280,
             details: "Budget rice packet with dhal and two curries.", category: "Lunch"),
        Meal(id: "m11", name: "Vegetable Kottu", vendor: "Night Bites", price: 450,
             details: "Kottu with mixed vegetables and gravy.", category: "Dinner"),
        Meal(id: "m12", name: "Chicken Fried Rice", vendor: "Night Bites", price: 580,
             details: "Chicken fried rice with devilled gravy.", category: "Dinner"),
        Meal(id: "m13", name: "Isso Wade (5)", vendor: "Campus Canteen", price: 250,
             details: "Crispy prawn wade with chilli sauce.", category: "Snacks"),
        Meal(id: "m14", name: "Fish Bun", vendor: "Campus Canteen", price: 120,
             details: "Warm fish bun, baked fresh.", category: "Snacks"),
        Meal(id: "m15", name: "Milk Tea & Short Eats", vendor: "Hostel Eats", price: 180,
             details: "A cup of milk tea with two short eats.", category: "Snacks")
    ]
}
