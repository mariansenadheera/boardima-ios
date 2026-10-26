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
    // Approximate values taken from the prototype. Check them with Figma's Inspect panel and adjust.
    static let navy = Color(hex: 0x0B1B3F)
    static let orange = Color(hex: 0xE8832A)
    static let brown = Color(hex: 0x8A4A12)
    static let green = Color(hex: 0x1E7A45)
    
    /// Deeper orange for text and button backgrounds.
    static let orangeStrong = Color(hex: 0xB45309)

    static let background = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let cornerRadius: CGFloat = 20
}

/// Rounded white card with a soft shadow, as used across the Figma screens.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

/// Small rounded label, as used for facilities and filters.
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

/// Full-width navy or orange button.
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
