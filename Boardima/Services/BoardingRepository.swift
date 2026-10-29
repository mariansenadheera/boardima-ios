import Foundation

protocol BoardingRepositoryProtocol {
    func fetchBoardings() async throws -> [Boarding]
}


struct SampleBoardingRepository: BoardingRepositoryProtocol {
    func fetchBoardings() async throws -> [Boarding] {
        try await Task.sleep(for: .milliseconds(300))
        return Boarding.samples
    }
}
