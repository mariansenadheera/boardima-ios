import Foundation

struct MatchSample: Identifiable {
    let id: Int
    let budget: Double
    let rent: Double
    let distanceKm: Double
    let roomType: String
    let preferredRoomType: String
    let facilityCount: Double
    let rating: Double
    let actualScore: Double
}

/// Reads the bundled local test dataset (not Firebase) used to demonstrate the Core ML model.
enum MatchDatasetLoader {
    static func loadTestSamples() -> [MatchSample] {
        guard let url = Bundle.main.url(forResource: "boardima_match_test", withExtension: "csv"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }

        let lines = text.split(whereSeparator: \.isNewline).dropFirst()   // skip header row
        var samples: [MatchSample] = []

        for (index, line) in lines.enumerated() {
            let c = line.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
            guard c.count >= 8,
                  let budget = Double(c[0]), let rent = Double(c[1]),
                  let distance = Double(c[2]), let facilities = Double(c[5]),
                  let rating = Double(c[6]), let actual = Double(c[7]) else { continue }

            samples.append(MatchSample(id: index, budget: budget, rent: rent, distanceKm: distance,
                                       roomType: c[3], preferredRoomType: c[4],
                                       facilityCount: facilities, rating: rating,
                                       actualScore: actual))
        }
        return samples
    }
}
