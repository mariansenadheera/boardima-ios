import SwiftUI
import MapKit

struct BoardingDetailView: View {
    let boarding: Boarding
    @Environment(SavedViewModel.self) private var saved

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(boarding.title).font(.title.bold())
                    Text(boarding.address).foregroundStyle(.secondary)
                }

                HStack(spacing: 24) {
                    stat("Rent", "Rs. \(boarding.monthlyRent)")
                    stat("Room", boarding.roomType)
                    stat("Distance", String(format: "%.1f km", boarding.distanceToUniversityKm))
                    stat("Rating", String(format: "%.1f ★", boarding.rating))
                }
                Map(initialPosition: .region(MKCoordinateRegion(center: boarding.coordinate,
                                                                latitudinalMeters: 800,
                                                                longitudinalMeters: 800)),
                    interactionModes: []) {
                    Marker(boarding.title, systemImage: "house.fill", coordinate: boarding.coordinate)
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel("Map showing \(boarding.title)")

                Divider()

                Text("Facilities").font(.headline)
                ForEach(boarding.facilities, id: \.self) { facility in
                    Label(facility, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.primary, .green)
                }
            }
            .padding()
        }
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

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline.bold())
        }
        .accessibilityElement(children: .combine)
    }
}
