import Foundation
import Observation

@MainActor
@Observable
final class AppLockViewModel {
    private static let key = "faceIDLockEnabled"

    var isLocked: Bool
    var isFaceIDEnabled: Bool

    private let biometrics: BiometricAuthServiceProtocol

    var isBiometryAvailable: Bool { biometrics.isAvailable }
    var biometryName: String { biometrics.biometryName }

    init(biometrics: BiometricAuthServiceProtocol? = nil) {
        self.biometrics = biometrics ?? BiometricAuthService()
        let enabled = UserDefaults.standard.bool(forKey: Self.key)
        self.isFaceIDEnabled = enabled
        self.isLocked = enabled   // lock on cold launch if enabled
    }

    func lockIfNeeded() {
        if isFaceIDEnabled { isLocked = true }
    }

    func unlock() async {
        let ok = await biometrics.authenticate(reason: "Unlock Boardima")
        if ok { isLocked = false }
    }

    /// Enabling requires a successful check first, so the user can't lock themselves out.
    func setEnabled(_ enabled: Bool) async {
        if enabled {
            let ok = await biometrics.authenticate(reason: "Turn on \(biometryName) for Boardima")
            guard ok else { return }
        }
        isFaceIDEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: Self.key)
    }
}
