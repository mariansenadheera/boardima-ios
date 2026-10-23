import SwiftUI

struct BoardingListView: View {
    @Environment(BoardingListViewModel.self) private var viewModel
    @Environment(SavedViewModel.self) private var saved
    @Environment(MatchViewModel.self) private var match
    @State private var showFilters = false
    
    private var displayed: [Boarding] {
        let items = viewModel.filtered
        guard viewModel.sortByMatch else { return items }
        return items.sorted { (match.score(for: $0) ?? 0) > (match.score(for: $1) ?? 0) }
    }

    var body: some View {
        @Bindable var model = viewModel

        NavigationStack {
            List(displayed) { boarding in
                NavigationLink(value: boarding) {
                    BoardingRow(boarding: boarding, isSaved: saved.isSaved(boarding.id),
                                match: match.score(for: boarding))
                }
            }
            .overlay {
                if model.isLoading {
                    ProgressView()
                } else if model.filtered.isEmpty {
                    ContentUnavailableView("No boardings found", systemImage: "magnifyingglass",
                                           description: Text("Try changing your search or filters."))
                }
            }
            .navigationTitle("Find Boarding")
            .navigationDestination(for: Boarding.self) { BoardingDetailView(boarding: $0) }
            .searchable(text: $model.searchText, prompt: "Search by name or area")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        BoardingMapView()
                    } label: {
                        Image(systemName: "map")
                    }
                    .accessibilityLabel("Show map")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: model.hasActiveFilters
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filters")
                }
            }
            .sheet(isPresented: $showFilters) { BoardingFilterView() }
            .refreshable { await model.load(force: true) }
            .task { await model.load() }
        }
    }
}
