import SwiftUI



struct AuthView: View {

    @Environment(AuthViewModel.self) private var auth



    @State private var isSignUp = false

    @State private var fullName = ""

    @State private var university = ""

    @State private var email = ""

    @State private var password = ""

    @State private var showPassword = false



    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                header

                fieldsCard



                if let message = auth.errorMessage {

                    Text(message)

                        .font(.footnote)

                        .foregroundStyle(.red)

                        .multilineTextAlignment(.center)

                }



                Button(action: submit) {

                    if auth.isLoading {

                        ProgressView().tint(.white)

                    } else {

                        HStack {

                            Text(isSignUp ? "Create account" : "Log in")

                            Image(systemName: "arrow.right")

                        }

                    }

                }

                .buttonStyle(BrandButtonStyle())

                .disabled(auth.isLoading)



                Button(isSignUp ? "Already have an account? Log in" : "New here? Create an account") {
                    isSignUp.toggle()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.brown)
                .frame(minHeight: 44)
                .contentShape(Rectangle())

            }

            .readableContentWidth(480)

            .padding(.horizontal, 24)

            .padding(.top, 48)

            .padding(.bottom, 24)

        }

        .background(Theme.background)

        .scrollDismissesKeyboard(.interactively)

        .onChange(of: isSignUp) { auth.errorMessage = nil }

    }



    //Pieces



    private var header: some View {

        VStack(spacing: 10) {

            LogoMark(size: 88)

                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)



            Text("Boardima")

                .font(.largeTitle.bold())

            Text(isSignUp ? "Create your student account" : "Your Student Living Companion")

                .foregroundStyle(.secondary)



            Label("Verified Student Network • Island-wide", systemImage: "checkmark.shield")

                .chipStyle(tint: Theme.brown)

                .padding(.top, 4)

        }

    }



    private var fieldsCard: some View {

        VStack(spacing: 0) {

            if isSignUp {

                fieldRow(icon: "person", title: "FULL NAME") {

                    TextField("Your full name", text: $fullName)

                        .textContentType(.name)

                        .accessibilityLabel("Full name")

                }

                Divider()

                fieldRow(icon: "building.columns", title: "UNIVERSITY") {

                    TextField("e.g. University of Moratuwa", text: $university)

                        .accessibilityLabel("University")

                }

                Divider()

            }



            fieldRow(icon: "envelope", title: "STUDENT EMAIL") {

                TextField("student@ac.lk", text: $email)

                    .textContentType(.emailAddress)

                    .keyboardType(.emailAddress)

                    .textInputAutocapitalization(.never)

                    .autocorrectionDisabled()

                    .accessibilityLabel("Student email")

            }

            Divider()



            HStack {

                fieldRow(icon: "lock", title: "PASSWORD") {

                    Group {

                        if showPassword {

                            TextField("Enter your password", text: $password)

                        } else {

                            SecureField("Enter your password", text: $password)

                        }

                    }

                    .textContentType(isSignUp ? .newPassword : .password)

                    .textInputAutocapitalization(.never)

                    .autocorrectionDisabled()

                    .accessibilityLabel("Password")

                }

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(showPassword ? "Hide password" : "Show password")
            }

        }

        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))

        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)

    }



    private func fieldRow<Content: View>(icon: String, title: String,

                                         @ViewBuilder content: () -> Content) -> some View {

        HStack(spacing: 14) {

            Image(systemName: icon)

                .foregroundStyle(.secondary)

                .frame(width: 24)

                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {

                Text(title)

                    .font(.caption.weight(.semibold))

                    .foregroundStyle(.secondary)

                content()

            }

        }

        .padding(.horizontal, 16)

        .padding(.vertical, 12)

    }



    private func submit() {

        Task {

            if isSignUp {

                await auth.signUp(fullName: fullName, university: university,

                                  email: email, password: password)

            } else {

                await auth.signIn(email: email, password: password)

            }

        }

    }

}



#Preview {

    AuthView()

        .environment(AuthViewModel(service: PreviewAuthService()))

}
