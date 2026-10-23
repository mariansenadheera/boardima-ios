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
                Label(boarding.address, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Rs. \(boarding.monthlyRent)/mo")
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 12) {
                    Label("\(boarding.distanceToUniversityKm, specifier: "%.1f") km",
                          systemImage: "figure.walk")
                    Label("\(boarding.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .foregroundStyle(.orange)
                }
                .font(.footnote)
                .labelStyle(.titleAndIcon)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                if let match {
                    Text("\(match)% match")
                        .font(.caption.bold())
                        .fixedSize()
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
