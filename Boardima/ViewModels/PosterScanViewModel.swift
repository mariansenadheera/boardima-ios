import UIKit
import Observation

@MainActor
@Observable
final class PosterScanViewModel {
    enum State: Equatable {
        case idle
        case scanning
        case found(Boarding)
        case notABoardimaCode
        case boardingMissing
        case noCode
        case failed(String)
    }

    private(set) var state: State = .idle
    private let scanner: PosterScanner

    init(scanner: PosterScanner = PosterScanner()) {
        self.scanner = scanner
    }

    func scan(imageData: Data, boardings: [Boarding]) async {
        state = .scanning
        guard let image = UIImage(data: imageData) else {
            state = .failed("That photo couldn't be opened.")
            return
        }
        do {
            let payloads = try await scanner.payloads(in: image)
            guard !payloads.isEmpty else {
                state = .noCode
                return
            }
            for payload in payloads {
                if let id = PosterLink.boardingID(from: payload) {
                    if let boarding = boardings.first(where: { $0.id == id }) {
                        state = .found(boarding)
                    } else {
                        state = .boardingMissing
                    }
                    return
                }
            }
            state = .notABoardimaCode
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func showFailure(_ message: String) { state = .failed(message) }
    func reset() { state = .idle }
}
