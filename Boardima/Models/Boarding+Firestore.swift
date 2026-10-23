import Foundation

extension Boarding {
    var firestoreData: [String: Any] {
        [
            "title": title,
            "address": address,
            "monthlyRent": monthlyRent,
            "roomType": roomType,
            "facilities": facilities,
            "rating": rating,
            "latitude": latitude,
            "longitude": longitude,
            "distanceToUniversityKm": distanceToUniversityKm
        ]
    }

    init?(id: String, data: [String: Any]) {
        guard let title = data["title"] as? String,
              let address = data["address"] as? String,
              let rent = data["monthlyRent"] as? Int,
              let roomType = data["roomType"] as? String,
              let facilities = data["facilities"] as? [String],
              let rating = data["rating"] as? Double,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double,
              let distance = data["distanceToUniversityKm"] as? Double
        else { return nil }

        self.init(id: id, title: title, address: address, monthlyRent: rent, roomType: roomType,
                  facilities: facilities, rating: rating, latitude: latitude, longitude: longitude,
                  distanceToUniversityKm: distance)
    }
}
