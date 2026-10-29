import Foundation
import Observation

enum AppTab: String, Hashable { case home, boardings, meals, saved, profile }


enum PendingNavigation {
    private static let key = "pendingTab"
    static func set(_ tab: AppTab) { UserDefaults.standard.set(tab.rawValue, forKey: key) }
    static func take() -> AppTab? {
        guard let raw = UserDefaults.standard.string(forKey: key) else { return nil }
        UserDefaults.standard.removeObject(forKey: key)
        return AppTab(rawValue: raw)
    }
}

@MainActor
@Observable
final class TabRouter {
    var selected: AppTab = .home
}
