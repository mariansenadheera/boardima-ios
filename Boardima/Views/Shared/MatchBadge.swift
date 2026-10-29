import SwiftUI


struct MatchBadge: View {
    let score: Int
    var size: CGFloat = 48

    private var ringColor: Color {
        score >= 70 ? Theme.green : (score >= 45 ? Theme.orange : Color.gray)
    }
    private var labelColor: Color {
        score >= 70 ? Theme.green : (score >= 45 ? Theme.brown : Color.secondary)
    }
    private var label: String {
        score >= 70 ? "Great match" : (score >= 45 ? "Fair match" : "Low match")
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().stroke(ringColor.opacity(0.2), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(score)%")
                    .font(.caption.bold())
                    .minimumScaleFactor(0.7)
            }
            .frame(width: size, height: size)

            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(labelColor)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(score) percent")
    }
}

#Preview {
    HStack(spacing: 24) {
        MatchBadge(score: 82)
        MatchBadge(score: 56)
        MatchBadge(score: 30)
    }
    .padding()
}
