import Foundation

extension Meal {
    var firestoreData: [String: Any] {
        [
            "name": name,
            "vendor": vendor,
            "price": price,
            "details": details,
            "category": category,
            "vendorLatitude": vendorLatitude,
            "vendorLongitude": vendorLongitude
        ]
    }

    init?(id: String, data: [String: Any]) {
        guard let name = data["name"] as? String,
              let vendor = data["vendor"] as? String,
              let price = data["price"] as? Int,
              let details = data["details"] as? String,
              let category = data["category"] as? String
        else { return nil }

        let latitude = data["vendorLatitude"] as? Double ?? Campus.moratuwa.latitude
        let longitude = data["vendorLongitude"] as? Double ?? Campus.moratuwa.longitude

        self.init(id: id, name: name, vendor: vendor, price: price, details: details,
                  category: category, vendorLatitude: latitude, vendorLongitude: longitude)
    }
}
