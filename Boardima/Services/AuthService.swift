import Foundation
import FirebaseAuth
import FirebaseFirestore

/// A readable error message to show on screen.
struct AuthFailure: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

/// Abstraction over the backend so view models can be unit tested with a mock.
protocol AuthServiceProtocol {
    var currentUserID: String? { get }
    var currentEmail: String? { get }
    func signUp(fullName: String, university: String, email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func fetchFullName() async -> String?
}

final class FirebaseAuthService: AuthServiceProtocol {
    private let db = Firestore.firestore()

    var currentUserID: String? { Auth.auth().currentUser?.uid }
    var currentEmail: String? { Auth.auth().currentUser?.email }

    func signUp(fullName: String, university: String, email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await db.collection("users").document(result.user.uid).setData([
                "fullName": fullName,
                "university": university,
                "email": email,
                "createdAt": Timestamp(date: Date())
            ])
        } catch {
            throw AuthFailure(message: Self.friendlyMessage(for: error))
        }
    }

    func signIn(email: String, password: String) async throws {
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw AuthFailure(message: Self.friendlyMessage(for: error))
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func fetchFullName() async -> String? {
        guard let uid = currentUserID else { return nil }
        let snapshot = try? await db.collection("users").document(uid).getDocument()
        return snapshot?.data()?["fullName"] as? String
    }

    private static func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError
        // Firebase Auth error codes (stable numbers, independent of the SDK version).
        switch nsError.code {
        case 17004, 17009, 17011:      // invalid credential, wrong password, user not found
            return "Incorrect email or password."
        case 17007:                    // email already in use
            return "An account with this email already exists."
        case 17026:                    // weak password
            return "Choose a stronger password (at least 6 characters)."
        case 17008:                    // invalid email
            return "Please enter a valid email address."
        case 17020:                    // network error
            return "No internet connection. Please try again."
        default:
            return error.localizedDescription
        }
    }
}

/// Stand-in used by previews and unit tests so they don't need Firebase.
struct PreviewAuthService: AuthServiceProtocol {
    var currentUserID: String? { nil }
    var currentEmail: String? { "student@example.com" }
    func signUp(fullName: String, university: String, email: String, password: String) async throws {}
    func signIn(email: String, password: String) async throws {}
    func signOut() throws {}
    func fetchFullName() async -> String? { "Preview Student" }
}
