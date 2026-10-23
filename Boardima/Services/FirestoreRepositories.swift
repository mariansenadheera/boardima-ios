import Foundation
import FirebaseAuth
import FirebaseFirestore

struct FirestoreBoardingRepository: BoardingRepositoryProtocol {
    func fetchBoardings() async throws -> [Boarding] {
        let snapshot = try await Firestore.firestore().collection("boardings").getDocuments()
        return snapshot.documents.compactMap { Boarding(id: $0.documentID, data: $0.data()) }
    }
}

struct FirestoreMealRepository: MealRepositoryProtocol {
    func fetchMeals() async throws -> [Meal] {
        let snapshot = try await Firestore.firestore().collection("meals").getDocuments()
        return snapshot.documents.compactMap { Meal(id: $0.documentID, data: $0.data()) }
    }
}

struct FirestoreOrderRepository: OrderRepositoryProtocol {
    func place(_ order: Order) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AuthFailure(message: "Please log in to place an order.")
        }

        let items: [[String: Any]] = order.lines.map { line in
            [
                "mealID": line.meal.id,
                "name": line.meal.name,
                "vendor": line.meal.vendor,
                "price": line.meal.price,
                "quantity": line.quantity
            ]
        }

        try await Firestore.firestore().collection("orders").document(order.id).setData([
            "userID": uid,
            "items": items,
            "total": order.total,
            "deliveryAddress": order.deliveryAddress,
            "phone": order.phone,
            "note": order.note,
            "paymentMethod": "cash_on_delivery",
            "status": "placed",
            "createdAt": Timestamp(date: order.placedAt)
        ])
    }
}

/// One-off helper that uploads the sample boardings and meals so the app has data to show.
struct FirestoreSeeder {
    func seed() async throws {
        let db = Firestore.firestore()
        let batch = db.batch()
        for boarding in Boarding.samples + Boarding.extraSeedData {
            batch.setData(boarding.firestoreData, forDocument: db.collection("boardings").document(boarding.id))
        }
        for meal in Meal.samples + Meal.extraSeedData {
            batch.setData(meal.firestoreData, forDocument: db.collection("meals").document(meal.id))
        }
        try await batch.commit()
    }
}
