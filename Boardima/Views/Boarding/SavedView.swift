import SwiftUI

struct SavedView: View {
    @Environment(BoardingListViewModel.self) private var listViewModel
    @Environment(SavedViewModel.self) private var saved

    private var items: [Boarding] {
        listViewModel.boardings.filter { saved.isSaved($0.id) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    ContentUnavailableView("No saved boardings", systemImage: "heart",
                                           description: Text("Tap the heart on a boarding to save it."))
                } else {
                    List(items) { boarding in
                        NavigationLink(value: boarding) {
                            BoardingRow(boarding: boarding, isSaved: true)
                        }
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationDestination(for: Boarding.self) { BoardingDetailView(boarding: $0) }
            .task { await listViewModel.load() }
        }
    }
}
