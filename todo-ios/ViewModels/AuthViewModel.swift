import Foundation
import SwiftUI
import Combine
import FirebaseAuth

// MARK: - Lab Assignment: Auth ViewModel (MVVM)
// Handles authentication UI logic, form inputs, validation, and communicates with AuthenticationManager.

@MainActor
class AuthViewModel: ObservableObject {
    // Input fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    // State indicators
    @Published var user: User?
    @Published var isProcessing = false
    @Published var errorMessage: String?

    private var authListener: AuthStateDidChangeListenerHandle?
    private let authManager = AuthenticationManager.shared

    init() {
        self.user = authManager.activeUser

        // Listen for login/logout state changes
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }

    deinit {
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    var isLoggedIn: Bool {
        return user != nil
    }

    var currentUserId: String? {
        return user?.uid
    }

    var userEmail: String {
        return user?.email ?? "User"
    }

    /// Sign In handler
    func signIn() async {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }

        isProcessing = true
        errorMessage = nil

        do {
            user = try await authManager.signInUser(email: cleanEmail, password: password)
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    /// Sign Up / Register handler
    func signUp() async {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all the required fields."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isProcessing = true
        errorMessage = nil

        do {
            user = try await authManager.registerUser(email: cleanEmail, password: password)
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    /// Sign Out handler
    func signOut() {
        do {
            try authManager.signOutUser()
            user = nil
            resetForm()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetForm() {
        email = ""
        password = ""
        confirmPassword = ""
    }

    func clearError() {
        errorMessage = nil
    }
}

