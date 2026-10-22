import Foundation
import CoreML
import Observation

/// Holds the student's matching preferences and scores boardings with the on-device Core ML model.
@MainActor
@Observable
final class MatchViewModel {
    static let roomTypes = ["Single", "Shared", "Twin", "Dormitory"]

    var budget: Double {
        didSet { UserDefaults.standard.set(budget, forKey: "pref.budget") }
    }
    var preferredRoomType: String {
        didSet { UserDefaults.standard.set(preferredRoomType, forKey: "pref.roomType") }
    }

    private let model: MLModel?

    init() {
        let saved = UserDefaults.standard.double(forKey: "pref.budget")
        self.budget = saved > 0 ? saved : 15000
        self.preferredRoomType = UserDefaults.standard.string(forKey: "pref.roomType") ?? "Single"

        if let url = Bundle.main.url(forResource: "BoardingMatch", withExtension: "mlmodelc") {
            self.model = try? MLModel(contentsOf: url)
        } else {
            self.model = nil
        }
    }

    var isModelAvailable: Bool { model != nil }

    /// Match percentage (0–100) for a boarding, or nil if the model isn't available.
    func score(for boarding: Boarding) -> Int? {
        predict(budget: budget,
                rent: Double(boarding.monthlyRent),
                distanceKm: boarding.distanceToUniversityKm,
                roomType: boarding.roomType,
                preferredRoomType: preferredRoomType,
                facilityCount: Double(boarding.facilities.count),
                rating: boarding.rating)
            .map { Int($0.rounded()) }
    }

    /// Raw prediction used by the app and by the Core ML demo screen.
    func predict(budget: Double, rent: Double, distanceKm: Double, roomType: String,
                 preferredRoomType: String, facilityCount: Double, rating: Double) -> Double? {
        guard let model else { return nil }

        let inputs: [String: MLFeatureValue] = [
            "userBudget": number(budget, for: "userBudget", in: model),
            "rent": number(rent, for: "rent", in: model),
            "distanceKm": number(distanceKm, for: "distanceKm", in: model),
            "roomType": MLFeatureValue(string: roomType),
            "preferredRoomType": MLFeatureValue(string: preferredRoomType),
            "facilityCount": number(facilityCount, for: "facilityCount", in: model),
            "rating": number(rating, for: "rating", in: model)
        ]

        do {
            let provider = try MLDictionaryFeatureProvider(dictionary: inputs)
            let output = try model.prediction(from: provider)
            guard let value = output.featureValue(for: "matchScore")?.doubleValue else { return nil }
            return min(100, max(0, value))
        } catch {
            return nil
        }
    }

    /// Create ML may treat whole-number columns as Int64, so match each input's declared type.
    private func number(_ value: Double, for name: String, in model: MLModel) -> MLFeatureValue {
        if model.modelDescription.inputDescriptionsByName[name]?.type == .int64 {
            return MLFeatureValue(int64: Int64(value))
        }
        return MLFeatureValue(double: value)
    }
}
