import MapKit

enum DirectionsError: LocalizedError {
    case noRoute

    var errorDescription: String? { "No route could be found." }
}

@MainActor
struct DirectionsService {
    func route(from origin: CLLocationCoordinate2D,
               to destination: CLLocationCoordinate2D,
               transport: MKDirectionsTransportType) async throws -> MKRoute {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = transport

        let response = try await MKDirections(request: request).calculate()
        guard let route = response.routes.first else { throw DirectionsError.noRoute }
        return route
    }
}
