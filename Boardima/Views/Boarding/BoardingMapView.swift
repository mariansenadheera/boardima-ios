import SwiftUI
import MapKit

struct BoardingMapView: View {
    @Environment(BoardingListViewModel.self) private var listViewModel
    @Environment(SavedViewModel.self) private var saved
    @Environment(CampusStore.self) private var campusStore
    @State private var mapViewModel = MapViewModel()
    @State private var location = LocationManager()
    @State private var position: MapCameraPosition = .automatic

    private let radiusOptions: [Double] = [0.5, 1, 2, 3, 5]

    private var campus: Campus { campusStore.selected }

    /// Search centre: the user's location if they're near the chosen campus, otherwise the campus.
    private var center: CLLocationCoordinate2D {
        guard let user = location.userLocation else { return campus.coordinate }
        return user.distance(from: campus.location) < 30_000 ? user.coordinate : campus.coordinate
    }

    private var usesUserLocation: Bool {
        guard let user = location.userLocation else { return false }
        return user.distance(from: campus.location) < 30_000
    }

    private var nearby: [Boarding] {
        mapViewModel.nearby(listViewModel.boardings, around: center)
    }

    private var selected: Boarding? {
        guard let id = mapViewModel.selectedBoardingID else { return nil }
        return listViewModel.boardings.first { $0.id == id }
    }

    var body: some View {
        Map(position: $position, selection: $mapViewModel.selectedBoardingID) {
            UserAnnotation()

            Annotation(campus.name, coordinate: campus.coordinate) {
                Image(systemName: "graduationcap.fill")
                    .padding(6)
                    .background(Theme.navy, in: Circle())
                    .foregroundStyle(.white)
            }

            MapCircle(center: center, radius: mapViewModel.radiusKm * 1000)
                .foregroundStyle(Theme.orange.opacity(0.10))
                .stroke(Theme.orange.opacity(0.6), lineWidth: 1)

            ForEach(nearby) { boarding in
                Marker(boarding.title,
                       systemImage: saved.isSaved(boarding.id) ? "heart.fill" : "house.fill",
                       coordinate: boarding.coordinate)
                    .tint(saved.isSaved(boarding.id) ? Color.red : Theme.navy)
                    .tag(boarding.id)
            }

            if let route = mapViewModel.route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 5)
            }

            if mapViewModel.straightLine.count == 2 {
                MapPolyline(coordinates: mapViewModel.straightLine)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 4, dash: [8, 6]))
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .safeAreaInset(edge: .top) { radiusBar }
        .safeAreaInset(edge: .bottom) {
            if let selected { card(for: selected) }
        }
        .navigationTitle("Boardings Map")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            location.requestPermission()
            recenter()
        }
        .task { await listViewModel.load() }
        .onChange(of: mapViewModel.selectedBoardingID) { mapViewModel.clearRoute() }
        .onChange(of: mapViewModel.radiusKm) { recenter() }
        .onChange(of: mapViewModel.route) { showWholeRoute() }
        .onChange(of: location.userLocation) { recenter() }
        .onChange(of: campusStore.selected) { recenter() }
    }

    // MARK: - Pieces

    private func radiusLabel(_ km: Double) -> String {
        km < 1 ? "\(Int(km * 1000)) m" : "\(Int(km)) km"
    }

    private var radiusBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(radiusOptions, id: \.self) { km in
                        FilterChip(title: radiusLabel(km),
                                   isSelected: mapViewModel.radiusKm == km) {
                            mapViewModel.radiusKm = km
                        }
                    }
                }
            }
            HStack {
                Text("\(nearby.count) boardings within \(radiusLabel(mapViewModel.radiusKm))")
                    .font(.subheadline.bold())
                Spacer()
                if !usesUserLocation {
                    Text("from \(campus.shortName)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            if !usesUserLocation {
                Text("Measuring from \(campus.name). Allow location access to search around you.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func card(for boarding: Boarding) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                PhotoView(name: PhotoLibrary.roomImageName(for: boarding.id), symbol: "bed.double.fill")
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(boarding.title).font(.headline)
                    Text("Rs. \(boarding.monthlyRent.formatted()) / mo · \(boarding.roomType)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Label("\(boarding.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.brown)
                }
                Spacer()
                Button {
                    saved.toggle(boarding)
                } label: {
                    Image(systemName: saved.isSaved(boarding.id) ? "heart.fill" : "heart")
                        .foregroundStyle(.red)
                }
                .accessibilityLabel(saved.isSaved(boarding.id) ? "Remove from saved" : "Save boarding")
            }

            Picker("Travel mode", selection: $mapViewModel.transport) {
                ForEach(TransportMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Button {
                    Task { await mapViewModel.showRoute(to: boarding, from: center) }
                } label: {
                    if mapViewModel.isRouting {
                        ProgressView()
                    } else {
                        Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.navy)

                NavigationLink(value: boarding) {
                    Text("Details")
                }
                .buttonStyle(.bordered)
                .tint(Theme.navy)

                if mapViewModel.hasRoute {
                    Button("Clear") { mapViewModel.clearRoute() }
                }
            }

            if let summary = mapViewModel.routeSummary {
                Text(summary).font(.footnote.bold())
            }
            if let message = mapViewModel.errorMessage {
                Text(message).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .padding(.bottom, 4)
    }

    // MARK: - Camera

    private func recenter() {
        let span = mapViewModel.radiusKm * 2400
        position = .region(MKCoordinateRegion(center: center,
                                              latitudinalMeters: span,
                                              longitudinalMeters: span))
    }

    private func showWholeRoute() {
        guard let route = mapViewModel.route else { return }
        let rect = route.polyline.boundingMapRect
        position = .rect(rect.insetBy(dx: -rect.width * 0.3, dy: -rect.height * 0.3))
    }
}
