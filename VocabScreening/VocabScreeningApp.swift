import SwiftUI

@main
struct VocabScreeningApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    AppScheduler.refreshIfNeeded()
                    _ = NotificationScheduler.shared // registers the UNUserNotificationCenter delegate
                }
        }
    }
}
