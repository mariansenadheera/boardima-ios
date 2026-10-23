import Foundation
import Observation

@MainActor
@Observable
final class BoardingListViewModel {
    var searchText = ""
    var maxRent: Double = 50000
    var selectedRoomType: String?
    var sortByMatch = false
    var isLoading = false
    var errorMessage: String?

    /// Only boardings within this many km of the selected campus are listed.
    let searchRadiusKm: Double = 8

    private var allBoardings: [Boarding] = []
    private let repository: BoardingRepositoryProtocol
    private let campusStore: CampusStore

    init(repository: BoardingRepositoryProtocol? = nil, campusStore: CampusStore? = nil) {
        self.repository = repository ?? FirestoreBoardingRepository()
        self.campusStore = campusStore ?? CampusStore.shared
    }

    /// Every loaded boarding, with its distance measured from the selected campus.
    var boardings: [Boarding] {
        let campus = campusStore.selected
        return allBoardings.map { boarding in
            var copy = boarding
            copy.distanceToUniversityKm = boarding.distance(from: campus)
            return copy
        }
    }

    var roomTypes: [String] {
        Array(Set(allBoardings.map(\.roomType))).sorted()
    }

    var filtered: [Boarding] {
        boardings.filter { boarding in
            let matchesSearch = searchText.isEmpty
                || boarding.title.localizedCaseInsensitiveContains(searchText)
                || boarding.address.localizedCaseInsensitiveContains(searchText)
            let matchesRent = Double(boarding.monthlyRent) <= maxRent
            let matchesType = selectedRoomType == nil || boarding.roomType == selectedRoomType
            let isNearby = boarding.distanceToUniversityKm <= searchRadiusKm
            return matchesSearch && matchesRent && matchesType && isNearby
        }
        .sorted { $0.distanceToUniversityKm < $1.distanceToUniversityKm }
    }

    var hasActiveFilters: Bool {
        selectedRoomType != nil || maxRent < 50000
    }

    func resetFilters() {
        selectedRoomType = nil
        maxRent = 50000
        sortByMatch = false
    }

    func load(force: Bool = false) async {
        guard force || allBoardings.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            allBoardings = try await repository.fetchBoardings()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
