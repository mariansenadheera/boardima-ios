import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

enum Theme {
    
    static let navy = Color(hex: 0x0B1B3F)
    static let orange = Color(hex: 0xE8832A)
    //static let brown = Color(hex: 0x8A4A12)
    // Navy for text and icons. Lighter in dark mode so it stays readable.
    static let ink = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.66, green: 0.76, blue: 1.0, alpha: 1)
            : UIColor(red: 0x0B / 255, green: 0x1B / 255, blue: 0x3F / 255, alpha: 1)
    })


    static let brown = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.94, green: 0.63, blue: 0.33, alpha: 1)
            : UIColor(red: 0x8A / 255, green: 0x4A / 255, blue: 0x12 / 255, alpha: 1)
    })
    static let green = Color(hex: 0x1E7A45)
    

    static let orangeStrong = Color(hex: 0xB45309)

    static let background = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let cornerRadius: CGFloat = 20
}


struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}


struct ChipStyle: ViewModifier {
    var tint: Color = Theme.navy
    func body(content: Content) -> some View {
        content
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.1), in: Capsule())
            .foregroundStyle(tint)
    }
}


struct BrandButtonStyle: ButtonStyle {
    var tint: Color = Theme.navy
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(tint, in: RoundedRectangle(cornerRadius: 16))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
    func chipStyle(tint: Color = Theme.navy) -> some View { modifier(ChipStyle(tint: tint)) }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var title: String {
        switch self {
        case .system: "System default"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
    var scheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

