import CoreLocation

struct Campus: Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let area: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    static let moratuwa = Campus(id: "uom", name: "University of Moratuwa", shortName: "Moratuwa",
                                 area: "Katubedda, Moratuwa", latitude: 6.7951, longitude: 79.9005)
    static let nibm = Campus(id: "nibm", name: "NIBM Colombo", shortName: "NIBM",
                             area: "Vidya Mawatha, Colombo 07", latitude: 6.9055, longitude: 79.8645)
    static let jayewardenepura = Campus(id: "sjp", name: "University of Sri Jayewardenepura",
                                        shortName: "Jayewardenepura",
                                        area: "Gangodawila, Nugegoda", latitude: 6.8530, longitude: 79.9030)

    static let all: [Campus] = [.moratuwa, .nibm, .jayewardenepura]
}
