import SwiftUI

// MARK: - Lab Assignment: Sign In Screen
// Features: Email & Password login, validation, navigation to register screen, Firebase Auth errors.

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Top Branding
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)

                            Image(systemName: "checklist.checked")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)

                        Text("Safi TaskHub")
                            .font(.system(size: 28, weight: .bold, design: .rounded))

                        Text("Organize your lab assignments & daily tasks")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Error Banner
                    if let err = authVM.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(err)
                                .font(.footnote)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.12))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // Form Fields
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email Address")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            TextField("Enter email", text: $authVM.email)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            SecureField("Enter password", text: $authVM.password)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    // Sign In Button
                    Button {
                        Task {
                            await authVM.signIn()
                        }
                    } label: {
                        HStack {
                            if authVM.isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .indigo.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .disabled(authVM.isProcessing)
                    .padding(.horizontal)

                    // Navigation to Sign Up
                    HStack(spacing: 4) {
                        Text("New here?")
                            .foregroundColor(.secondary)

                        NavigationLink(destination: SignUpView().environmentObject(authVM)) {
                            Text("Create an Account")
                                .fontWeight(.bold)
                                .foregroundColor(.indigo)
                        }
                    }
                    .font(.subheadline)
                    .padding(.top, 4)

                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}

