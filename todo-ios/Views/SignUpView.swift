import SwiftUI

// MARK: - Lab Assignment: Sign Up / Register Screen
// Features: Email & password validation (min 6 characters, password confirmation), Firebase account creation.

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 70, height: 70)

                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    Text("Create Account")
                        .font(.system(size: 26, weight: .bold, design: .rounded))

                    Text("Sign up to store your tasks securely in the cloud")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
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

                // Form Inputs
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email Address")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        TextField("Enter your email", text: $authVM.email)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password (at least 6 characters)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        SecureField("Create a password", text: $authVM.password)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Password")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        SecureField("Re-enter password", text: $authVM.confirmPassword)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                // Sign Up Button
                Button {
                    Task {
                        await authVM.signUp()
                    }
                } label: {
                    HStack {
                        if authVM.isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .purple.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .disabled(authVM.isProcessing)
                .padding(.horizontal)

                // Back to Login Link
                Button {
                    authVM.clearError()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Text("Already registered?")
                            .foregroundColor(.secondary)
                        Text("Sign In")
                            .fontWeight(.bold)
                            .foregroundColor(.indigo)
                    }
                    .font(.subheadline)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}

