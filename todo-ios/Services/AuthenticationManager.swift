import Foundation
import FirebaseAuth

// MARK: - Lab Assignment: Firebase Authentication Service
// TODO: Firebase Console -> Authentication -> Sign-in method e "Email/Password" enable korte hobe.
// TODO: GoogleService-Info.plist target membership check korte hobe.

/// Service class handling all Firebase Authentication tasks (Register, Sign In, Sign Out).
class AuthenticationManager {
    static let shared = AuthenticationManager()

    private init() {}

    /// Returns the currently authenticated Firebase user (or nil if logged out)
    var activeUser: User? {
        return Auth.auth().currentUser
    }

    /// Register a new user with Email and Password
    func registerUser(email: String, password: String) async throws -> User {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return authResult.user
    }

    /// Sign in an existing user with Email and Password
    func signInUser(email: String, password: String) async throws -> User {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return authResult.user
    }

    /// Sign out the current user session
    func signOutUser() throws {
        try Auth.auth().signOut()
    }
}

