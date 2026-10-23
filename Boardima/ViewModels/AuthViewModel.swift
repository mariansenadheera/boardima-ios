import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    var isAuthenticated: Bool
    var isLoading = false
    var errorMessage: String?
    private(set) var fullName = ""
    private(set) var email = ""

    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol? = nil) {
        let resolved = service ?? FirebaseAuthService()
        self.service = resolved
        self.isAuthenticated = resolved.currentUserID != nil
        self.email = resolved.currentEmail ?? ""
        if isAuthenticated {
            Task { await loadProfile() }
        }
    }

    func signIn(email: String, password: String) async {
        guard validate(email: email, password: password) else { return }
        await perform { try await self.service.signIn(email: email, password: password) }
    }

    func signUp(fullName: String, university: String, email: String, password: String) async {
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your full name."
            return
        }
        guard validate(email: email, password: password) else { return }
        await perform {
            try await self.service.signUp(fullName: fullName, university: university,
                                          email: email, password: password)
        }
    }

    func signOut() {
        do {
            try service.signOut()
            isAuthenticated = false
            fullName = ""
            email = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadProfile() async {
        email = service.currentEmail ?? ""
        fullName = await service.fetchFullName() ?? ""
    }

    private func validate(email: String, password: String) -> Bool {
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        return true
    }

    private func perform(_ action: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        do {
            try await action()
            isAuthenticated = true
            await loadProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
