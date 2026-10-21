import Foundation

protocol OrderRepositoryProtocol {
    func place(_ order: Order) async throws
}

/// Pretends to send the order. Replaced by a Firestore-backed repository later.
struct LocalOrderRepository: OrderRepositoryProtocol {
    func place(_ order: Order) async throws {
        try await Task.sleep(for: .milliseconds(600))
    }
}
