import Foundation


struct WidgetSnapshot: Codable, Equatable {
    var boardingID: String
    var title: String
    var rent: Int
    var distanceKm: Double
    var matchScore: Int?
    var campusName: String
    var savedCount: Int

    static let sample = WidgetSnapshot(boardingID: "1", title: "Green Villa Rooms", rent: 12000,
                                       distanceKm: 0.8, matchScore: 82,
                                       campusName: "Moratuwa", savedCount: 2)
}

enum SharedStore {
    static let groupID = "group.com.mariansenadheera.boardima"
    private static let key = "widgetSnapshot"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: groupID) ?? .standard
    }

    static func save(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
    }

    static func load() -> WidgetSnapshot? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
