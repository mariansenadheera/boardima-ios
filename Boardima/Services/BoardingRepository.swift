import Foundation

protocol BoardingRepositoryProtocol {
    func fetchBoardings() async throws -> [Boarding]
}

/// Local sample data. Replaced by a Firestore-backed repository in the Firebase step.
struct SampleBoardingRepository: BoardingRepositoryProtocol {
    func fetchBoardings() async throws -> [Boarding] {
        try await Task.sleep(for: .milliseconds(300))
        return Boarding.samples
    }
}
