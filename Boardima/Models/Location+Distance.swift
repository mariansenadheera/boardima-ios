import CoreLocation

extension Campus {
    /// A point `northKm` north and `eastKm` east of the campus.
    func offset(northKm: Double, eastKm: Double) -> (latitude: Double, longitude: Double) {
        let lat = latitude + northKm / 110.574
        let lon = longitude + eastKm / (111.320 * cos(latitude * .pi / 180))
        return (lat, lon)
    }
}

extension Boarding {
    /// Straight-line distance to a campus in kilometres.
    func distance(from campus: Campus) -> Double {
        CLLocation(latitude: latitude, longitude: longitude).distance(from: campus.location) / 1000
    }
}

extension Meal {
    /// Straight-line distance from the vendor to a campus in kilometres.
    func distance(from campus: Campus) -> Double {
        CLLocation(latitude: vendorLatitude, longitude: vendorLongitude).distance(from: campus.location) / 1000
    }

    func placed(near campus: Campus, northKm: Double, eastKm: Double) -> Meal {
        var copy = self
        let point = campus.offset(northKm: northKm, eastKm: eastKm)
        copy.vendorLatitude = point.latitude
        copy.vendorLongitude = point.longitude
        return copy
    }
}
