import SwiftUI
import MapKit

struct BoardingDetailView: View {
    let boarding: Boarding
    @Environment(SavedViewModel.self) private var saved
    @Environment(CampusStore.self) private var campusStore
    @Environment(MatchViewModel.self) private var match

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var campus: Campus { campusStore.selected }
    private var distanceKm: Double { boarding.distance(from: campus) }
    private var walkMinutes: Int { max(1, Int((distanceKm / 5 * 60).rounded())) }

    private struct Reason: Identifiable {
        let text: String
        let isGood: Bool
        var id: String { text }
    }

    /// Plain-language comparison of this listing with the student's preferences.
    private var reasons: [Reason] {
        let budget = Int(match.budget)
        var items: [Reason] = []

        if boarding.monthlyRent <= budget {
            items.append(Reason(text: "Rs. \(boarding.monthlyRent.formatted()) is within your Rs. \(budget.formatted()) budget", isGood: true))
        } else {
            items.append(Reason(text: "Rs. \((boarding.monthlyRent - budget).formatted()) above your Rs. \(budget.formatted()) budget", isGood: false))
        }

        if boarding.roomType == match.preferredRoomType {
            items.append(Reason(text: "\(boarding.roomType) room, as you prefer", isGood: true))
        } else {
            items.append(Reason(text: "You prefer a \(match.preferredRoomType) room, this is \(boarding.roomType)", isGood: false))
        }

        if distanceKm <= 1.0 {
            items.append(Reason(text: String(format: "Walkable: %.1f km from %@", distanceKm, campus.shortName), isGood: true))
        } else {
            items.append(Reason(text: String(format: "%.1f km from %@", distanceKm, campus.shortName), isGood: false))
        }

        items.append(Reason(text: String(format: "Rated %.1f by students", boarding.rating), isGood: boarding.rating >= 4.0))
        return items
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PhotoView(name: PhotoLibrary.roomImageName(for: boarding.id), symbol: "bed.double.fill")
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .overlay(alignment: .bottomTrailing) {
                        Label("\(boarding.rating, specifier: "%.1f")", systemImage: "star.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(Theme.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.regularMaterial, in: Capsule())
                            .padding(12)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(boarding.roomType.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.brown)
                    Text(boarding.title).font(.title.bold())
                    Label(boarding.address, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(.secondary)
                }

                if let score = match.score(for: boarding) {
                    matchCard(score: score)
                }

                HStack {
                    stat("Monthly rent", "Rs. \(boarding.monthlyRent.formatted())")
                    Divider().frame(height: 36)
                    stat("Room", boarding.roomType)
                    Divider().frame(height: 36)
                    stat("From \(campus.shortName)", String(format: "%.1f km", distanceKm))
                }
                .cardStyle()

                VStack(spacing: 0) {
                    Label("\(distanceKm, specifier: "%.1f") km from \(campus.shortName) • about \(walkMinutes) min walk",
                          systemImage: "figure.walk")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.brown)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Theme.orange.opacity(0.12))

                    Map(initialPosition: .region(MKCoordinateRegion(center: boarding.coordinate,
                                                                    latitudinalMeters: 800,
                                                                    longitudinalMeters: 800)),
                        interactionModes: []) {
                        Marker(boarding.title, systemImage: "house.fill", coordinate: boarding.coordinate)
                    }
                    .frame(height: 180)
                    .accessibilityLabel("Map showing \(boarding.title)")
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

                HStack(spacing: 14) {
                    AvatarView(imageName: "avatar-owner", initials: "O", size: 56)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your host").font(.headline)
                        Text("Owner of \(boarding.title)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .cardStyle()
                .accessibilityElement(children: .combine)

                Text("Essential amenities")
                    .font(.title3.bold())
                    .accessibilityAddTraits(.isHeader)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(boarding.facilities, id: \.self) { facility in
                        HStack(spacing: 10) {
                            Image(systemName: icon(for: facility))
                                .foregroundStyle(Theme.navy)
                                .frame(width: 36, height: 36)
                                .background(Theme.navy.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                                .accessibilityHidden(true)
                            Text(facility).font(.subheadline.weight(.medium))
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .readableContentWidth(720)
            .padding()
        }
        .background(Theme.background)
        .navigationTitle(boarding.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    saved.toggle(boarding)
                } label: {
                    Image(systemName: saved.isSaved(boarding.id) ? "heart.fill" : "heart")
                        .foregroundStyle(saved.isSaved(boarding.id) ? .red : .accentColor)
                }
                .accessibilityLabel(saved.isSaved(boarding.id) ? "Remove from saved" : "Save boarding")
            }
        }
    }

    private func matchCard(score: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 16) {
                MatchBadge(score: score, size: 64).frame(width: 90)
                VStack(alignment: .leading, spacing: 4) {
                    Text("How well this fits you").font(.headline)
                    Text("Based on your budget, room type and this listing.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Divider()
            ForEach(reasons) { reason in
                Label {
                    Text(reason.text).font(.subheadline)
                } icon: {
                    Image(systemName: reason.isGood ? "checkmark.circle.fill" : "minus.circle.fill")
                        .foregroundStyle(reason.isGood ? Theme.green : Theme.orange)
                }
            }
            Text("The score is predicted on your device by a Core ML model. Change your budget and room type in Profile.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func icon(for facility: String) -> String {
        switch facility.lowercased() {
        case "wifi": "wifi"
        case "meals": "fork.knife"
        case "laundry": "washer"
        case "ac": "snowflake"
        case "attached bathroom": "shower"
        case "study room": "book"
        case "parking": "car"
        default: "checkmark.circle"
        }
    }
}
