import Foundation
import CoreLocation

struct Boarding: Identifiable, Hashable {
    let id: String
    var title: String
    var address: String
    var monthlyRent: Int
    var roomType: String
    var facilities: [String]
    var rating: Double
    var latitude: Double
    var longitude: Double
    var distanceToUniversityKm: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: Boarding, rhs: Boarding) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    static let samples: [Boarding] = [
        Boarding(id: "1", title: "Green Villa Rooms", address: "Katubedda, Moratuwa",
                 monthlyRent: 12000, roomType: "Shared", facilities: ["WiFi", "Meals", "Laundry"],
                 rating: 4.2, latitude: 6.7951, longitude: 79.8936, distanceToUniversityKm: 0.8),
        Boarding(id: "2", title: "Campus Edge Annex", address: "Rawatawatta, Moratuwa",
                 monthlyRent: 18000, roomType: "Single", facilities: ["WiFi", "Attached bathroom"],
                 rating: 4.6, latitude: 6.7890, longitude: 79.8870, distanceToUniversityKm: 1.4),
        Boarding(id: "3", title: "Lakeview Boarding", address: "Koralawella, Moratuwa",
                 monthlyRent: 9500, roomType: "Shared", facilities: ["Meals", "Study room"],
                 rating: 3.9, latitude: 6.7845, longitude: 79.8812, distanceToUniversityKm: 2.1),
        Boarding(id: "4", title: "Scholar's Nest", address: "Katubedda Junction",
                 monthlyRent: 22000, roomType: "Single", facilities: ["WiFi", "AC", "Laundry", "Attached bathroom"],
                 rating: 4.8, latitude: 6.7968, longitude: 79.8951, distanceToUniversityKm: 0.5),
        Boarding(id: "5", title: "Budget Bunk House", address: "Moratuwa Town",
                 monthlyRent: 7000, roomType: "Dormitory", facilities: ["WiFi", "Meals"],
                 rating: 3.5, latitude: 6.7730, longitude: 79.8826, distanceToUniversityKm: 3.0),
        Boarding(id: "6", title: "Twin Palms Residence", address: "Piliyandala Road",
                 monthlyRent: 15000, roomType: "Twin", facilities: ["WiFi", "Laundry", "Parking"],
                 rating: 4.3, latitude: 6.7912, longitude: 79.9005, distanceToUniversityKm: 1.9)
    ]
}
