import SwiftUI

struct CoreMLDemoView: View {
    @Environment(MatchViewModel.self) private var match

    private struct Result: Identifiable {
        let sample: MatchSample
        let predicted: Double
        var id: Int { sample.id }
        var error: Double { predicted - sample.actualScore }
    }

    @State private var results: [Result] = []
    @State private var hasRun = false

    private var meanAbsoluteError: Double {
        guard !results.isEmpty else { return 0 }
        return results.map { abs($0.error) }.reduce(0, +) / Double(results.count)
    }

    private var rmse: Double {
        guard !results.isEmpty else { return 0 }
        return (results.map { $0.error * $0.error }.reduce(0, +) / Double(results.count)).squareRoot()
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Rows tested", value: "\(results.count)")
                LabeledContent("Mean absolute error", value: String(format: "%.2f points", meanAbsoluteError))
                LabeledContent("RMSE", value: String(format: "%.2f points", rmse))
            } header: {
                Text("Accuracy on the separate test dataset")
            } footer: {
                Text("Predictions run on this device with Core ML. The data is a bundled CSV, not Firebase.")
            }

            if hasRun && results.isEmpty {
                Section {
                    Text("No results. Check that boardima_match_test.csv and BoardingMatch.mlmodel are in the app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("First 40 predictions") {
                ForEach(Array(results.prefix(40))) { result in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(result.sample.roomType) · Rs. \(Int(result.sample.rent)) · \(result.sample.distanceKm, specifier: "%.1f") km · \(result.sample.rating, specifier: "%.1f")★")
                            .font(.subheadline)
                        Text("Wants \(result.sample.preferredRoomType) · budget Rs. \(Int(result.sample.budget))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text("Predicted \(result.predicted, specifier: "%.1f")")
                            Spacer()
                            Text("Actual \(result.sample.actualScore, specifier: "%.1f")")
                                .foregroundStyle(.secondary)
                        }
                        .font(.footnote.bold())
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .navigationTitle("Core ML Demo")
        .navigationBarTitleDisplayMode(.inline)
        .task { runModel() }
    }

    private func runModel() {
        guard !hasRun else { return }
        results = MatchDatasetLoader.loadTestSamples().compactMap { sample in
            guard let predicted = match.predict(budget: sample.budget, rent: sample.rent,
                                                distanceKm: sample.distanceKm,
                                                roomType: sample.roomType,
                                                preferredRoomType: sample.preferredRoomType,
                                                facilityCount: sample.facilityCount,
                                                rating: sample.rating) else { return nil }
            return Result(sample: sample, predicted: predicted)
        }
        hasRun = true
    }
}
