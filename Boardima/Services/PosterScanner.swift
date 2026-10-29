
import UIKit
import CoreImage
import ImageIO

/// Reads QR codes from a selected poster photo.
struct PosterScanner {

    func payloads(in image: UIImage) async throws -> [String] {
        return try await Task.detached(priority: .userInitiated) {
            guard let ciImage = CIImage(image: image) else {
                return []
            }

            let context = CIContext()

            guard let detector = CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: context,
                options: [
                    CIDetectorAccuracy: CIDetectorAccuracyHigh
                ]
            ) else {
                throw PosterScannerError.detectorUnavailable
            }

            let features = detector.features(in: ciImage)

            return features
                .compactMap { $0 as? CIQRCodeFeature }
                .compactMap { $0.messageString }
        }.value
    }
}

enum PosterScannerError: LocalizedError {
    case detectorUnavailable

    var errorDescription: String? {
        switch self {
        case .detectorUnavailable:
            return "Could not initialize QR code detector."
        }
    }
}


/// The link stored in a Boardima poster QR code, for example boardima://boarding/nibm-1
enum PosterLink {
    static func boardingID(from payload: String) -> String? {
        let text = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: text),
              url.scheme == "boardima",
              url.host == "boarding" else { return nil }
        let id = url.lastPathComponent
        return (id.isEmpty || id == "/") ? nil : id
    }
}

/// Converts a photo's UIKit orientation to the one Vision expects.
extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
