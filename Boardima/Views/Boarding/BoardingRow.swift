import SwiftUI

struct BoardingRow: View {
    let boarding: Boarding
    let isSaved: Bool

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

            if isSaved {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .accessibilityLabel("Saved")
            }
        }
        .accessibilityElement(children: .combine)
    }
}
