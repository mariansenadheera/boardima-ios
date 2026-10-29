import Foundation

protocol OrderRepositoryProtocol {
    func place(_ order: Order) async throws
}


struct LocalOrderRepository: OrderRepositoryProtocol {
    func place(_ order: Order) async throws {
        try await Task.sleep(for: .milliseconds(600))
    }
}
