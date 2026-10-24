import SwiftUI

struct BoardingRow: View {
    let boarding: Boarding
    let isSaved: Bool
    var match: Int? = nil
    var onToggleSave: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            photo

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("Rs. \(boarding.monthlyRent.formatted())")
                        .font(.title2.bold())
                    Text("/ mo").foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "star.fill").foregroundStyle(Theme.orange)
                    Text("\(boarding.rating, specifier: "%.1f")").bold()
                }

                HStack(spacing: 6) {
                    Text(boarding.roomType).chipStyle(tint: Theme.brown)
                    ForEach(boarding.facilities.prefix(2), id: \.self) { facility in
                        Text(facility).chipStyle()
                    }
                    if boarding.facilities.count > 2 {
                        Text("+\(boarding.facilities.count - 2)").chipStyle(tint: .secondary)
                    }
                }
                .lineLimit(1)

                if let match {
                    MatchStrip(score: match)
                }
            }
            .padding(14)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 3)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Photo with title on top

    private var photo: some View {
        PhotoView(name: PhotoLibrary.roomImageName(for: boarding.id), symbol: "bed.double.fill")
            .frame(height: 190)
            .overlay {
                LinearGradient(colors: [.clear, .black.opacity(0.7)],
                               startPoint: .center, endPoint: .bottom)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(boarding.title)
                        .font(.title3.bold())
                        .lineLimit(2)
                    Label(boarding.address, systemImage: "mappin.and.ellipse")
                        .font(.footnote)
                        .lineLimit(1)
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(14)
            }
            .overlay(alignment: .topLeading) {
                Label("\(boarding.distanceToUniversityKm, specifier: "%.1f") km", systemImage: "figure.walk")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(12)
            }
            .overlay(alignment: .topTrailing) {
                Button { onToggleSave?() } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundStyle(isSaved ? Color.red : Theme.navy)
                        .padding(10)
                        .background(.regularMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .disabled(onToggleSave == nil)
                .accessibilityLabel(isSaved ? "Remove from saved" : "Save boarding")
                .padding(8)
            }
    }
}

// MARK: - Match strip

private struct MatchStrip: View {
    let score: Int

    private var color: Color {
        score >= 70 ? Theme.green : (score >= 45 ? Theme.orange : Color.gray)
    }
    private var textColor: Color {
        score >= 70 ? Theme.green : (score >= 45 ? Theme.brown : Color.secondary)
    }
    private var label: String {
        score >= 70 ? "Great match" : (score >= 45 ? "Fair match" : "Low match")
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(label) for you")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(textColor)
                    Spacer()
                    Text("\(score)%").font(.subheadline.bold())
                }
                ProgressView(value: Double(score), total: 100)
                    .tint(color)
            }
        }
        .padding(12)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) for you, \(score) percent")
    }
}
