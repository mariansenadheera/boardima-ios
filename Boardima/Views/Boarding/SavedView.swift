import SwiftUI

struct SavedView: View {
    @Environment(BoardingListViewModel.self) private var listViewModel
    @Environment(SavedViewModel.self) private var saved
    @Environment(MatchViewModel.self) private var match
    @Environment(CampusStore.self) private var campusStore
    @State private var showAll = false

    private var allSaved: [Boarding] {
        listViewModel.boardings.filter { saved.isSaved($0.id) }
    }

    private var nearCampus: [Boarding] {
        allSaved
            .filter { $0.distanceToUniversityKm <= listViewModel.searchRadiusKm }
            .sorted { $0.distanceToUniversityKm < $1.distanceToUniversityKm }
    }

    private var items: [Boarding] { showAll ? allSaved : nearCampus }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Saved")
                        .font(.title2.bold())
                        .accessibilityAddTraits(.isHeader)
                    if !allSaved.isEmpty {
                        Picker("Show", selection: $showAll) {
                            Text("Near \(campusStore.selected.shortName) (\(nearCampus.count))").tag(false)
                            Text("All saved (\(allSaved.count))").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 8)

                if allSaved.isEmpty {
                    ContentUnavailableView("No saved boardings", systemImage: "heart",
                                           description: Text("Tap the heart on a boarding to save it."))
                } else if items.isEmpty {
                    ContentUnavailableView {
                        Label("Nothing saved near \(campusStore.selected.shortName)", systemImage: "heart")
                    } description: {
                        Text("Your saved boardings are near other campuses.")
                    } actions: {
                        Button("Show all saved") { showAll = true }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: AdaptiveColumns.cards(), spacing: 16) {
                            ForEach(items) { boarding in
                                NavigationLink(value: boarding) {
                                    BoardingRow(boarding: boarding, isSaved: true,
                                                match: match.score(for: boarding),
                                                onToggleSave: { saved.toggle(boarding) })
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                Spacer(minLength: 0)
            }
            .background(Theme.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Boarding.self) { BoardingDetailView(boarding: $0) }
            .task { await listViewModel.load() }
        }
    }
}
