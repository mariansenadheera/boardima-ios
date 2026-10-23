import Foundation
import UserNotifications
import Observation

/// Lets banners show even while the app is open.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}

@MainActor
@Observable
final class NotificationManager {
    private static let reminderKey = "pref.dailyReminder"
    private static let reminderID = "daily-saved-reminder"

    private(set) var isAuthorized = false
    private(set) var remindersEnabled: Bool

    @ObservationIgnored private let center = UNUserNotificationCenter.current()
    @ObservationIgnored private let delegate = NotificationDelegate()

    init() {
        remindersEnabled = UserDefaults.standard.bool(forKey: Self.reminderKey)
        center.delegate = delegate
    }

    func refreshStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = Self.allows(settings.authorizationStatus)
    }

    /// Asks for permission the first time. Returns whether notifications are allowed.
    func ensurePermission() async -> Bool {
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            isAuthorized = granted
            return granted
        }
        isAuthorized = Self.allows(settings.authorizationStatus)
        return isAuthorized
    }

    /// Simulates the vendor's status updates. A production app would send these from a server.
    func scheduleOrderUpdates(for order: Order) async {
        guard await ensurePermission() else { return }

        let steps: [(delay: TimeInterval, title: String, body: String)] = [
            (2, "Order received", "Your order of \(order.lines.count) item(s) has been sent to the vendor."),
            (10, "Being prepared", "The vendor is preparing your meal."),
            (25, "On the way", "Please have Rs. \(order.total) ready in cash.")
        ]

        for (index, step) in steps.enumerated() {
            await schedule(id: "order-\(order.id)-\(index)",
                           title: step.title,
                           body: step.body,
                           trigger: UNTimeIntervalNotificationTrigger(timeInterval: step.delay, repeats: false))
        }
    }

    func sendTestNotification() async {
        guard await ensurePermission() else { return }
        await schedule(id: "test-\(UUID().uuidString)",
                       title: "Boardima",
                       body: "Notifications are working.",
                       trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false))
    }

    func setRemindersEnabled(_ enabled: Bool) async {
        if enabled {
            guard await ensurePermission() else { return }
            var time = DateComponents()
            time.hour = 18
            time.minute = 0
            await schedule(id: Self.reminderID,
                           title: "Still looking for a boarding?",
                           body: "Your saved boardings are waiting. Compare them before you decide.",
                           trigger: UNCalendarNotificationTrigger(dateMatching: time, repeats: true))
        } else {
            center.removePendingNotificationRequests(withIdentifiers: [Self.reminderID])
        }
        remindersEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: Self.reminderKey)
    }

    // MARK: - Helpers

    private static func allows(_ status: UNAuthorizationStatus) -> Bool {
        status == .authorized || status == .provisional || status == .ephemeral
    }

    private func schedule(id: String, title: String, body: String, trigger: UNNotificationTrigger) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try? await center.add(request)
    }
}
