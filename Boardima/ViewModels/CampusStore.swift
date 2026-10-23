import Foundation
import Observation

/// The campus the student is heading to today. Saved on the device between launches.
@MainActor
@Observable
final class CampusStore {
    static let shared = CampusStore()
    private static let key = "selectedCampusID"

    var selected: Campus {
        didSet {
            if persists { UserDefaults.standard.set(selected.id, forKey: Self.key) }
        }
    }

    @ObservationIgnored private let persists: Bool

    /// Pass a campus to get an isolated store that doesn't touch saved settings (used in unit tests).
    init(selected: Campus? = nil) {
        if let selected {
            self.selected = selected
            self.persists = false
        } else {
            let id = UserDefaults.standard.string(forKey: Self.key)
            self.selected = Campus.all.first { $0.id == id } ?? .moratuwa
            self.persists = true
        }
    }
}
