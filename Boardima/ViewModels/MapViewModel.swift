import Foundation
import MapKit
import Observation

enum TransportMode: String, CaseIterable, Identifiable {
    case walking = "Walk"
    case driving = "Drive"

    var id: String { rawValue }

    var mapKitType: MKDirectionsTransportType {
        self == .walking ? .walking : .automobile
    }
}

@MainActor
@Observable
final class MapViewModel {
    var radiusKm: Double = 3
    var selectedBoardingID: String?
    var transport: TransportMode = .walking

    private(set) var route: MKRoute?
    private(set) var straightLine: [CLLocationCoordinate2D] = []
    private(set) var routeSummary: String?
    private(set) var isRouting = false
    private(set) var errorMessage: String?

    private let directions: DirectionsService

    init(directions: DirectionsService? = nil) {
        self.directions = directions ?? DirectionsService()
    }

    var hasRoute: Bool { route != nil || !straightLine.isEmpty }

    /// Boardings within the chosen radius of the centre point.
    func nearby(_ boardings: [Boarding], around center: CLLocationCoordinate2D) -> [Boarding] {
        let centre = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return boardings.filter { boarding in
            let location = CLLocation(latitude: boarding.latitude, longitude: boarding.longitude)
            return location.distance(from: centre) <= radiusKm * 1000
        }
    }

    func showRoute(to boarding: Boarding, from origin: CLLocationCoordinate2D) async {
        clearRoute()
        isRouting = true
        defer { isRouting = false }

        do {
            let result = try await directions.route(from: origin, to: boarding.coordinate,
                                                    transport: transport.mapKitType)
            route = result
            let minutes = max(1, Int((result.expectedTravelTime / 60).rounded()))
            routeSummary = "\(minutes) min · \(String(format: "%.1f", result.distance / 1000)) km"
        } catch {
            // Fall back to a straight line so the demo still works offline or where routing is limited.
            let from = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
            let to = CLLocation(latitude: boarding.latitude, longitude: boarding.longitude)
            straightLine = [origin, boarding.coordinate]
            routeSummary = "≈ \(String(format: "%.1f", from.distance(from: to) / 1000)) km in a straight line"
            errorMessage = "Turn-by-turn directions aren't available right now, so a straight line is shown."
        }
    }

    func clearRoute() {
        route = nil
        straightLine = []
        routeSummary = nil
        errorMessage = nil
    }
}
