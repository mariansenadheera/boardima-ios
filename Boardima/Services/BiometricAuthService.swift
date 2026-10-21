import LocalAuthentication

protocol BiometricAuthServiceProtocol {
    var isAvailable: Bool { get }
    var biometryName: String { get }
    func authenticate(reason: String) async -> Bool
}

struct BiometricAuthService: BiometricAuthServiceProtocol {
    var isAvailable: Bool {
        var error: NSError?
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    var biometryName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometrics"
        }
    }

    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                    localizedReason: reason)
        } catch {
            return false
        }
    }
}
