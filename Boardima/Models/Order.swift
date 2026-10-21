import Foundation

struct Order: Identifiable {
    let id: String
    let lines: [CartLine]
    let total: Int
    let deliveryAddress: String
    let phone: String
    let note: String
    let placedAt: Date
}
