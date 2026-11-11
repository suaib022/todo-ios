import SwiftUI
import FirebaseCore

// MARK: - 👾 Mobile Computing Lab Assignment: Todo App
// App: todo-ios
// Features:
// - Firebase Authentication (Email / Password registration & sign-in)
// - Cloud Firestore database storage for user tasks
// - Full CRUD operations (Create, Read, Update, Delete, Toggle Complete)
// - Task Title, Description, Priority (High, Medium, Low) & Timestamp
// - User-isolated data security (whereField userId == request.auth.uid)

@main
struct TodoApp: App {

    init() {
        // Initialize Firebase SDK
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
        }
    }
}

