import SwiftUI

struct BoardingListView: View {
    @Environment(BoardingListViewModel.self) private var viewModel
    @Environment(SavedViewModel.self) private var saved
    @State private var showFilters = false

    var body: some View {
        @Bindable var model = viewModel

        NavigationStack {
            List(model.filtered) { boarding in
                NavigationLink(value: boarding) {
                    BoardingRow(boarding: boarding, isSaved: saved.isSaved(boarding.id))
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
            .task { await model.load() }
        }
    }
}
