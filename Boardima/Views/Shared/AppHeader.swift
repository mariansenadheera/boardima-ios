import SwiftUI

/// Logo mark from the asset catalog ("Logo"), with a fallback icon.
struct LogoMark: View {
    var size: CGFloat = 40

    var body: some View {
        Group {
            if UIImage(named: "Logo") != nil {
                Image("Logo").resizable().scaledToFit()
            } else {
                ZStack {
                    Theme.navy
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: size * 0.5))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.25))
        .accessibilityHidden(true)
    }
}

/// Top bar used on every tab: logo and name on the left, profile photo on the right.
struct AppHeader: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(TabRouter.self) private var router

    private var initials: String {
        let letters = auth.fullName.split(separator: " ").prefix(2).compactMap(\.first)
        return letters.isEmpty ? "S" : String(letters).uppercased()
    }

    var body: some View {
        HStack(spacing: 10) {
            LogoMark(size: 38)
            Text("Boardima")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            Spacer()
            Button {
                router.selected = .profile
            } label: {
                AvatarView(imageName: "avatar-user", initials: initials, size: 38)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Theme.background)
    }
}

/// Round icon button background used for map, filter and cart.
struct CircleIcon: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.body.weight(.semibold))
            .foregroundStyle(.primary)
            .frame(width: 40, height: 40)
            .background(Theme.card, in: Circle())
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

/// Search box used instead of the navigation bar search.
struct SearchField: View {
    let prompt: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField(prompt, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}
