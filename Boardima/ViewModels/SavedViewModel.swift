import Foundation
import Observation

@MainActor
@Observable
final class SavedViewModel {
    private(set) var savedIDs: Set<String>
    private let store: SavedBoardingStore

    init(store: SavedBoardingStore? = nil) {
        let resolved = store ?? SavedBoardingStore()
        self.store = resolved
        self.savedIDs = resolved.fetchIDs()
    }

    func isSaved(_ id: String) -> Bool { savedIDs.contains(id) }

    func toggle(_ boarding: Boarding) {
        if savedIDs.contains(boarding.id) {
            store.remove(id: boarding.id)
            savedIDs.remove(boarding.id)
        } else {
            store.save(boarding)
            savedIDs.insert(boarding.id)
        }
    }
}
