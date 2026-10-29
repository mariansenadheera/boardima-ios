import Foundation
import Observation

@MainActor
@Observable
final class MealsViewModel {
    var meals: [Meal] = []
    var searchText = ""
    var selectedCategory: String?
    var isLoading = false
    var errorMessage: String?

    let searchRadiusKm: Double = 8

    private let repository: MealRepositoryProtocol
    private let campusStore: CampusStore

    init(repository: MealRepositoryProtocol? = nil, campusStore: CampusStore? = nil) {
        self.repository = repository ?? FirestoreMealRepository()
        self.campusStore = campusStore ?? CampusStore.shared
    }

    var categories: [String] {
        Array(Set(meals.map(\.category))).sorted()
    }

    var filtered: [Meal] {
        let campus = campusStore.selected
        return meals.filter { meal in
            let matchesSearch = searchText.isEmpty
                || meal.name.localizedCaseInsensitiveContains(searchText)
                || meal.vendor.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || meal.category == selectedCategory
            let isNearby = meal.distance(from: campus) <= searchRadiusKm
            return matchesSearch && matchesCategory && isNearby
        }
        .sorted { $0.distance(from: campus) < $1.distance(from: campus) }
    }

    func load(force: Bool = false) async {
        guard force || meals.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            meals = try await repository.fetchMeals()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
