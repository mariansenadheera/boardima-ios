import Foundation
import Observation

@MainActor
@Observable
final class BoardingListViewModel {
    var boardings: [Boarding] = []
    var searchText = ""
    var maxRent: Double = 50000
    var selectedRoomType: String?
    var sortByMatch = false
    var isLoading = false
    var errorMessage: String?

    private let repository: BoardingRepositoryProtocol

    init(repository: BoardingRepositoryProtocol? = nil) {
        self.repository = repository ?? SampleBoardingRepository()
    }

    var roomTypes: [String] {
        Array(Set(boardings.map(\.roomType))).sorted()
    }

    var filtered: [Boarding] {
        boardings.filter { boarding in
            let matchesSearch = searchText.isEmpty
                || boarding.title.localizedCaseInsensitiveContains(searchText)
                || boarding.address.localizedCaseInsensitiveContains(searchText)
            let matchesRent = Double(boarding.monthlyRent) <= maxRent
            let matchesType = selectedRoomType == nil || boarding.roomType == selectedRoomType
            return matchesSearch && matchesRent && matchesType
        }
        .sorted { $0.distanceToUniversityKm < $1.distanceToUniversityKm }
    }

    var hasActiveFilters: Bool {
        selectedRoomType != nil || maxRent < 50000
    }

    func resetFilters() {
        sortByMatch = false
        selectedRoomType = nil
        maxRent = 50000
    }

    func load() async {
        guard boardings.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            boardings = try await repository.fetchBoardings()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
