import SwiftUI

struct AuthView: View {
    @Environment(AuthViewModel.self) private var auth

    @State private var isSignUp = false
    @State private var fullName = ""
    @State private var university = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "house.lodge.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                    .padding(.top, 40)
                    .accessibilityHidden(true)

                Text("Boardima")
                    .font(.largeTitle.bold())
                Text(isSignUp ? "Create your student account" : "Welcome back")
                    .foregroundStyle(.secondary)

                Picker("Mode", selection: $isSignUp) {
                    Text("Log in").tag(false)
                    Text("Sign up").tag(true)
                }
                .pickerStyle(.segmented)
                .onChange(of: isSignUp) { auth.errorMessage = nil }

                if isSignUp {
                    TextField("Full name", text: $fullName)
                        .textContentType(.name)
                        .textFieldStyle(.roundedBorder)
                    TextField("University", text: $university)
                        .textFieldStyle(.roundedBorder)
                }

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textContentType(isSignUp ? .newPassword : .password)
                    .textFieldStyle(.roundedBorder)

                if let message = auth.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        if isSignUp {
                            await auth.signUp(fullName: fullName, university: university,
                                              email: email, password: password)
                        } else {
                            await auth.signIn(email: email, password: password)
                        }
                    }
                } label: {
                    Group {
                        if auth.isLoading {
                            ProgressView()
                        } else {
                            Text(isSignUp ? "Create account" : "Log in")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(auth.isLoading)
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    AuthView()
        .environment(AuthViewModel(service: PreviewAuthService()))
}
