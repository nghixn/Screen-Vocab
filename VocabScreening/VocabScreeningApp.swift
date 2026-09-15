import SwiftUI

@main
struct VocabScreeningApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    AppScheduler.refreshIfNeeded()
                }
        }
    }
}
