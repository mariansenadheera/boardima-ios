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
                 rating: 4.6, latitude: 6.7890, longitude: 79.8870, distanceToUniversityKm: 1.4)
    ]
}
