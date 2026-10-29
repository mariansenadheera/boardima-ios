import SwiftUI

struct DashboardView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(CampusStore.self) private var campusStore
    @Environment(BoardingListViewModel.self) private var boardingList
    @Environment(MealsViewModel.self) private var mealsViewModel
    @Environment(MatchViewModel.self) private var match
    @Environment(SavedViewModel.self) private var saved
    @Environment(TabRouter.self) private var router
    
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var showScanner = false

    private var firstName: String {
        auth.fullName.split(separator: " ").first.map(String.init) ?? ""
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        case 17..<22: "Good evening"
        default: "Hello"
        }
    }

    private var recommended: [Boarding] {
        Array(boardingList.filtered
            .sorted { (match.score(for: $0) ?? 0) > (match.score(for: $1) ?? 0) }
            .prefix(3))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        greetingBlock
                        quickActions
                        scanButton
                        recommendedSection
                        mealsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .refreshable {
                    await boardingList.load(force: true)
                    await mealsViewModel.load(force: true)
                }
            }
            .background(Theme.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Boarding.self) { BoardingDetailView(boarding: $0) }
            .task {
                await boardingList.load()
                await mealsViewModel.load()
            }
            .sheet(isPresented: $showScanner) { PosterScanView() }
        }
    }

    // MARK: - Sections

    private var greetingBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(firstName.isEmpty ? "Hi there, \(greeting)!" : "Hi \(firstName), \(greeting)!")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Menu {
                Picker("Campus", selection: Bindable(campusStore).selected) {
                    ForEach(Campus.all) { campus in
                        Text(campus.name).tag(campus)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "graduationcap")
                    Text(campusStore.selected.name).lineLimit(1)
                    Image(systemName: "chevron.down").font(.caption)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Theme.card, in: Capsule())
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            }
            .accessibilityLabel("Campus: \(campusStore.selected.name). Tap to change.")

            Label("Showing places within \(Int(boardingList.searchRadiusKm)) km of campus",
                  systemImage: "location.circle")
                .font(.footnote)
                .foregroundStyle(Theme.ink)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.navy.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var quickActions: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
        return layout {
            tile("Find Boarding", symbol: "building.2.fill", fill: Theme.navy) {
                router.selected = .boardings
            }
            tile("Order Lunch", symbol: "fork.knife", fill: Theme.orangeStrong) {
                router.selected = .meals
            }
        }
    }
    
    private var scanButton: some View {
        Button {
            showScanner = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Theme.navy.opacity(0.08), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Scan a boarding poster").font(.subheadline.weight(.semibold))
                    Text("Read the QR code on a poster and open the boarding")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .padding(12)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func tile(_ title: String, symbol: String, fill: Color,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.title2)
                    .frame(width: 48, height: 48)
                    .background(.white.opacity(0.2), in: Circle())
                Text(title).font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(fill, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Recommended for you", action: "See all") { router.selected = .boardings }

            if recommended.isEmpty {
                Text("No boardings found near this campus yet.").foregroundStyle(.secondary)
            }
            
            LazyVGrid(columns: AdaptiveColumns.cards(), spacing: 16) {
                ForEach(recommended) { boarding in
                    NavigationLink(value: boarding) {
                        BoardingRow(boarding: boarding,
                                    isSaved: saved.isSaved(boarding.id),
                                    match: match.score(for: boarding),
                                    onToggleSave: { saved.toggle(boarding) })
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Today's meals near campus", action: "View menu") { router.selected = .meals }

            let items = Array(mealsViewModel.filtered.prefix(6))
            if items.isEmpty {
                Text("No food providers found near this campus yet.").foregroundStyle(.secondary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { meal in
                        MealCard(meal: meal)
                    }
                }
                .padding(.vertical, 8)
            }
            .scrollClipDisabled()
        }
    }

    private func sectionHeader(_ title: String, action: String,
                               perform: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button(action, action: perform)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.brown)
        }
    }
}
