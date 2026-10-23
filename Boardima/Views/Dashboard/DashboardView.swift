import SwiftUI

struct DashboardView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(CampusStore.self) private var campusStore
    @Environment(BoardingListViewModel.self) private var boardingList
    @Environment(MealsViewModel.self) private var mealsViewModel
    @Environment(MatchViewModel.self) private var match
    @Environment(SavedViewModel.self) private var saved

    private var title: String {
        let first = auth.fullName.split(separator: " ").first.map(String.init) ?? ""
        return first.isEmpty ? "Boardima" : "Hi, \(first)"
    }

    var body: some View {
        @Bindable var store = campusStore

        NavigationStack {
            List {
                Section("Today I'm going to") {
                    Picker("Campus", selection: $store.selected) {
                        ForEach(Campus.all) { campus in
                            Text(campus.name).tag(campus)
                        }
                    }
                }

                Section("Boardings near \(campusStore.selected.shortName)") {
                    let items = Array(boardingList.filtered.prefix(3))
                    if items.isEmpty {
                        Text("No boardings found near this campus yet.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(items) { boarding in
                        NavigationLink(value: boarding) {
                            BoardingRow(boarding: boarding,
                                        isSaved: saved.isSaved(boarding.id),
                                        match: match.score(for: boarding))
                        }
                    }
                }

                Section("Food near \(campusStore.selected.shortName)") {
                    let items = Array(mealsViewModel.filtered.prefix(3))
                    if items.isEmpty {
                        Text("No food providers found near this campus yet.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(items) { meal in
                        MealRow(meal: meal)
                    }
                }
            }
            .navigationTitle(title)
            .navigationDestination(for: Boarding.self) { BoardingDetailView(boarding: $0) }
            .task {
                await boardingList.load()
                await mealsViewModel.load()
            }
            .refreshable {
                await boardingList.load(force: true)
                await mealsViewModel.load(force: true)
            }
        }
    }
}
