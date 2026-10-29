import WidgetKit

enum WidgetPublisher {
    @MainActor
    static func publish(list: BoardingListViewModel, match: MatchViewModel,
                        saved: SavedViewModel, campus: Campus) {
        let best = list.filtered.max {
            (match.score(for: $0) ?? 0) < (match.score(for: $1) ?? 0)
        }
        guard let top = best else { return }
        SharedStore.save(WidgetSnapshot(boardingID: top.id,
                                        title: top.title,
                                        rent: top.monthlyRent,
                                        distanceKm: top.distanceToUniversityKm,
                                        matchScore: match.score(for: top),
                                        campusName: campus.shortName,
                                        savedCount: saved.savedIDs.count))
        WidgetCenter.shared.reloadAllTimelines()
    }
}
