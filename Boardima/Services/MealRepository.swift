import Foundation

protocol MealRepositoryProtocol {
    func fetchMeals() async throws -> [Meal]
}

/// Local sample data. Replaced by a Firestore-backed repository later.
struct SampleMealRepository: MealRepositoryProtocol {
    func fetchMeals() async throws -> [Meal] {
        try await Task.sleep(for: .milliseconds(300))
        return Meal.samples
    }
}
