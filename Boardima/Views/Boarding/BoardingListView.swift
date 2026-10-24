import SwiftUI

struct BoardingListView: View {
    @Environment(BoardingListViewModel.self) private var viewModel
    @Environment(SavedViewModel.self) private var saved
    @Environment(MatchViewModel.self) private var match
    @Environment(CampusStore.self) private var campusStore
    @State private var showFilters = false

    private var displayed: [Boarding] {
        let items = viewModel.filtered
        guard viewModel.sortByMatch else { return items }
        return items.sorted { (match.score(for: $0) ?? 0) > (match.score(for: $1) ?? 0) }
    }

    var body: some View {
        @Bindable var model = viewModel

        NavigationStack {
            VStack(spacing: 0) {
                AppHeader()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            Text("Find Boarding").font(.title2.bold())
                            Spacer()
                            NavigationLink {
                                BoardingMapView()
                            } label: {
                                CircleIcon(symbol: "map")
                            }
                            .accessibilityLabel("Show map")

                            Button {
                                showFilters = true
                            } label: {
                                CircleIcon(symbol: model.hasActiveFilters
                                           ? "line.3.horizontal.decrease.circle.fill"
                                           : "line.3.horizontal.decrease.circle")
                            }
                            .accessibilityLabel("Filters")
                        }

                        SearchField(prompt: "Search by name or area", text: $model.searchText)

                        Text("\(displayed.count) boardings within \(Int(viewModel.searchRadiusKm)) km of \(campusStore.selected.shortName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ForEach(displayed) { boarding in
                            NavigationLink(value: boarding) {
                                BoardingRow(boarding: boarding,
                                            isSaved: saved.isSaved(boarding.id),
                                            match: match.score(for: boarding),
                                            onToggleSave: { saved.toggle(boarding) })
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .scrollDismissesKeyboard(.interactively)
                .refreshable { await model.load(force: true) }
                .overlay {
                    if model.isLoading {
                        ProgressView()
                    } else if model.filtered.isEmpty {
                        ContentUnavailableView("No boardings found", systemImage: "magnifyingglass",
                                               description: Text("Try changing your search or filters."))
                    }
                }
            }
            .background(Theme.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Boarding.self) { BoardingDetailView(boarding: $0) }
            .sheet(isPresented: $showFilters) { BoardingFilterView() }
            .task { await model.load() }
        }
    }
}
