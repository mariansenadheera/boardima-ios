import SwiftUI

struct BoardingRow: View {
    let boarding: Boarding
    let isSaved: Bool
    
    var match: Int? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "house.fill")
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(boarding.title).font(.headline)
                Text(boarding.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Text("Rs. \(boarding.monthlyRent)/mo")
                    Text("·")
                    Text("\(boarding.distanceToUniversityKm, specifier: "%.1f") km")
                    Text("·")
                    Label("\(boarding.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(.orange)
                }
                .font(.footnote)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                if let match {
                    Text("\(match)% match")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(match >= 70 ? Color.green.opacity(0.2) : Color.orange.opacity(0.2),
                                    in: Capsule())
                        .foregroundStyle(match >= 70 ? .green : .orange)
                }
                if isSaved {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                        .accessibilityLabel("Saved")
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
