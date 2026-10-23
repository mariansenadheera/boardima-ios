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

    private let repository: MealRepositoryProtocol

    init(repository: MealRepositoryProtocol? = nil) {
        self.repository = repository ?? FirestoreMealRepository()
    }

    var categories: [String] {
        Array(Set(meals.map(\.category))).sorted()
    }

    var filtered: [Meal] {
        meals.filter { meal in
            let matchesSearch = searchText.isEmpty
                || meal.name.localizedCaseInsensitiveContains(searchText)
                || meal.vendor.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || meal.category == selectedCategory
            return matchesSearch && matchesCategory
        }
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
