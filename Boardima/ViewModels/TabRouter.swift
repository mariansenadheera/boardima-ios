import Foundation
import Observation

enum AppTab: Hashable { case home, boardings, meals, saved, profile }

@MainActor
@Observable
final class TabRouter {
    var selected: AppTab = .home
}
