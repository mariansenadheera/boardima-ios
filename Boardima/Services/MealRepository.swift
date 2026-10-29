import Foundation

protocol MealRepositoryProtocol {
    func fetchMeals() async throws -> [Meal]
}


struct SampleMealRepository: MealRepositoryProtocol {
    func fetchMeals() async throws -> [Meal] {
        try await Task.sleep(for: .milliseconds(300))
        return Meal.samples
    }
}
