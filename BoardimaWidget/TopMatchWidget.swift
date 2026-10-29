import WidgetKit
import SwiftUI

struct TopMatchEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct TopMatchProvider: TimelineProvider {
    func placeholder(in context: Context) -> TopMatchEntry {
        TopMatchEntry(date: .now, snapshot: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (TopMatchEntry) -> Void) {
        completion(TopMatchEntry(date: .now, snapshot: SharedStore.load() ?? .sample))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TopMatchEntry>) -> Void) {
        let entry = TopMatchEntry(date: .now, snapshot: SharedStore.load() ?? .sample)
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600))))
    }
}

struct TopMatchWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TopMatchEntry

    private let navy = Color(red: 0x0B / 255, green: 0x1B / 255, blue: 0x3F / 255)
    private let orange = Color(red: 0xB4 / 255, green: 0x53 / 255, blue: 0x09 / 255)

    var body: some View {
        let s = entry.snapshot
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Top match", systemImage: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(orange)
                Spacer()
                if let score = s.matchScore {
                    Text("\(score)%")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(navy, in: Capsule())
                        .foregroundStyle(.white)
                }
            }
            Text(s.title)
                .font(family == .systemSmall ? .headline : .title3.weight(.bold))
                .foregroundStyle(navy)
                .lineLimit(2)
            Text("Rs. \(s.rent.formatted()) / month")
                .font(.subheadline)
                .foregroundStyle(.black)
            Spacer(minLength: 0)
            HStack {
                Label(String(format: "%.1f km from %@", s.distanceKm, s.campusName),
                      systemImage: "figure.walk")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if family == .systemMedium {
                    Spacer()
                    Label("\(s.savedCount) saved", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .widgetURL(URL(string: "boardima://boarding/\(s.boardingID)"))
        .containerBackground(.white, for: .widget)
    }
}

struct TopMatchWidget: Widget {
    let kind = "TopMatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TopMatchProvider()) { entry in
            TopMatchWidgetView(entry: entry)
        }
        .configurationDisplayName("Top boarding match")
        .description("Your best-matching boarding near campus.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
