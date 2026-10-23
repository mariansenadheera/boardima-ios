import SwiftUI
import MapKit

struct BoardingMapView: View {
    @Environment(BoardingListViewModel.self) private var listViewModel
    @Environment(SavedViewModel.self) private var saved
    @State private var mapViewModel = MapViewModel()
    @State private var location = LocationManager()
    @State private var position: MapCameraPosition = .automatic

    /// Search centre: the user's location if allowed, otherwise the university.
    //private var center: CLLocationCoordinate2D {
        //location.userLocation?.coordinate ?? Campus.coordinate
    //}
    
    /// Search centre: the user's location if they're near the campus, otherwise the university.
    private var center: CLLocationCoordinate2D {
        guard let user = location.userLocation else { return Campus.coordinate }
        let campus = CLLocation(latitude: Campus.coordinate.latitude,
                                longitude: Campus.coordinate.longitude)
        return user.distance(from: campus) < 30_000 ? user.coordinate : Campus.coordinate
    }

    private var usesUserLocation: Bool {
        guard let user = location.userLocation else { return false }
        let campus = CLLocation(latitude: Campus.coordinate.latitude,
                                longitude: Campus.coordinate.longitude)
        return user.distance(from: campus) < 30_000
    }
    
    //end

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

            Annotation(Campus.name, coordinate: Campus.coordinate) {
                Image(systemName: "graduationcap.fill")
                    .padding(6)
                    .background(.indigo, in: Circle())
                    .foregroundStyle(.white)
            }

            MapCircle(center: center, radius: mapViewModel.radiusKm * 1000)
                .foregroundStyle(.blue.opacity(0.08))
                .stroke(.blue.opacity(0.5), lineWidth: 1)

            ForEach(nearby) { boarding in
                Marker(boarding.title,
                       systemImage: saved.isSaved(boarding.id) ? "heart.fill" : "house.fill",
                       coordinate: boarding.coordinate)
                    .tint(saved.isSaved(boarding.id) ? .red : .blue)
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
    }

    // MARK: - Pieces

    private var radiusBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Within \(mapViewModel.radiusKm, specifier: "%.1f") km")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(nearby.count) boardings")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Slider(value: $mapViewModel.radiusKm, in: 0.5...5, step: 0.5)
                .accessibilityLabel("Search radius in kilometres")
            if !usesUserLocation {
                Text("Measuring from \(Campus.name). Allow location access to search around you.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    private func card(for boarding: Boarding) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(boarding.title).font(.headline)
                    Text("Rs. \(boarding.monthlyRent)/mo · \(boarding.roomType)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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

                NavigationLink(value: boarding) {
                    Text("Details")
                }
                .buttonStyle(.bordered)

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
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
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
