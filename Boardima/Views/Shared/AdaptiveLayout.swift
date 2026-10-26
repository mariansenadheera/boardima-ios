import SwiftUI

extension View {
    /// Centres content and limits its width on large screens such as iPad.
    func readableContentWidth(_ maxWidth: CGFloat = 720) -> some View {
        frame(maxWidth: maxWidth).frame(maxWidth: .infinity)
    }

    /// Sidebar tab bar on iPad (iOS 18 and later); unchanged on iPhone.
    @ViewBuilder
    func adaptiveTabStyle() -> some View {
        if #available(iOS 18.0, *) {
            tabViewStyle(.sidebarAdaptable)
        } else {
            self
        }
    }
}

enum AdaptiveColumns {
    /// One column on iPhone, two or three on iPad, depending on the window width.
    static func cards(minimum: CGFloat = 320) -> [GridItem] {
        [GridItem(.adaptive(minimum: minimum), spacing: 16, alignment: .top)]
    }
}
