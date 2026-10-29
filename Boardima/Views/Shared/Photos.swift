import SwiftUI
import UIKit


enum PhotoLibrary {
    static let roomCount = count(prefix: "room")
    static let foodCount = count(prefix: "food")

    static func roomImageName(for id: String) -> String? { name("room", roomCount, id) }
    static func foodImageName(for id: String) -> String? { name("food", foodCount, id) }

    private static func count(prefix: String) -> Int {
        var n = 0
        while UIImage(named: "\(prefix)-\(n + 1)") != nil { n += 1 }
        return n
    }

    private static func name(_ prefix: String, _ count: Int, _ id: String) -> String? {
        guard count > 0 else { return nil }
        
        let seed = id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return "\(prefix)-\(seed % count + 1)"
    }
}


struct PhotoView: View {
    let name: String?
    let symbol: String

    var body: some View {
        Color.clear
            .overlay {
                if let name {
                    Image(name).resizable().scaledToFill()
                } else {
                    ZStack {
                        Theme.navy.opacity(0.08)
                        Image(systemName: symbol)
                            .font(.largeTitle)
                            .foregroundStyle(Theme.navy.opacity(0.4))
                    }
                }
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

struct AvatarView: View {
    let imageName: String
    var initials: String = ""
    var size: CGFloat = 56

    var body: some View {
        Group {
            if UIImage(named: imageName) != nil {
                Image(imageName).resizable().scaledToFill()
            } else {
                ZStack {
                    Theme.navy
                    Text(initials.isEmpty ? "?" : initials)
                        .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .accessibilityHidden(true)
    }
}
