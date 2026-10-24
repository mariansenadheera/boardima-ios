import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.navy : Theme.card, in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .overlay(Capsule().stroke(Color.primary.opacity(isSelected ? 0 : 0.12)))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
