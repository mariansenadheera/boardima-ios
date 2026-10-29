import Foundation
import Observation

@MainActor
@Observable
final class CartViewModel {
    private(set) var lines: [CartLine] = []
    var isPlacing = false
    var errorMessage: String?

    private let repository: OrderRepositoryProtocol

    init(repository: OrderRepositoryProtocol? = nil) {
        self.repository = repository ?? FirestoreOrderRepository()
    }

    var itemCount: Int { lines.reduce(0) { $0 + $1.quantity } }
    var total: Int { lines.reduce(0) { $0 + $1.meal.price * $1.quantity } }

    func quantity(of meal: Meal) -> Int {
        lines.first { $0.meal.id == meal.id }?.quantity ?? 0
    }

    func add(_ meal: Meal) {
        if let index = lines.firstIndex(where: { $0.meal.id == meal.id }) {
            lines[index].quantity += 1
        } else {
            lines.append(CartLine(meal: meal, quantity: 1))
        }
    }

    func remove(_ meal: Meal) {
        guard let index = lines.firstIndex(where: { $0.meal.id == meal.id }) else { return }
        if lines[index].quantity > 1 {
            lines[index].quantity -= 1
        } else {
            lines.remove(at: index)
        }
    }

    func clear() {
        lines.removeAll()
        errorMessage = nil
    }

    
    func placeOrder(address: String, phone: String, note: String) async -> Order? {
        let address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = phone.filter(\.isNumber)

        guard !lines.isEmpty else {
            errorMessage = "Your cart is empty."
            return nil
        }
        guard !address.isEmpty else {
            errorMessage = "Please enter a delivery address."
            return nil
        }
        guard digits.count >= 9 else {
            errorMessage = "Please enter a valid phone number."
            return nil
        }

        isPlacing = true
        errorMessage = nil
        defer { isPlacing = false }

        let order = Order(id: UUID().uuidString, lines: lines, total: total,
                          deliveryAddress: address, phone: phone, note: note,
                          placedAt: Date())
        do {
            try await repository.place(order)
            return order
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
