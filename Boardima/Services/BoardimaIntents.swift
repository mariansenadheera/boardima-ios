import AppIntents

struct FindBoardingsIntent: AppIntent {
    static let title: LocalizedStringResource = "Find boardings near campus"
    static let description = IntentDescription("Opens the Boardima boardings list.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        PendingNavigation.set(.boardings)
        return .result()
    }
}

struct OrderLunchIntent: AppIntent {
    static let title: LocalizedStringResource = "Order lunch"
    static let description = IntentDescription("Opens the Boardima meals menu.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        PendingNavigation.set(.meals)
        return .result()
    }
}

struct ShowSavedBoardingsIntent: AppIntent {
    static let title: LocalizedStringResource = "Show saved boardings"
    static let description = IntentDescription("Opens your saved boardings in Boardima.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        PendingNavigation.set(.saved)
        return .result()
    }
}

struct BoardimaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: FindBoardingsIntent(),
                    phrases: ["Find boardings in \(.applicationName)",
                              "Show boardings in \(.applicationName)"],
                    shortTitle: "Find boardings", systemImageName: "bed.double")
        AppShortcut(intent: OrderLunchIntent(),
                    phrases: ["Order lunch in \(.applicationName)"],
                    shortTitle: "Order lunch", systemImageName: "fork.knife")
        AppShortcut(intent: ShowSavedBoardingsIntent(),
                    phrases: ["Show my saved boardings in \(.applicationName)"],
                    shortTitle: "Saved boardings", systemImageName: "heart")
    }
}
