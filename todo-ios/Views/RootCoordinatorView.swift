import SwiftUI

// MARK: - Lab Assignment: Root View Coordinator
// Listens to AuthViewModel and automatically routes between Authentication and Task Dashboard.

struct RootCoordinatorView: View {
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                TaskDashboardView()
                    .environmentObject(authVM)
            } else {
                SignInView()
                    .environmentObject(authVM)
            }
        }
    }
}

#Preview {
    RootCoordinatorView()
}

