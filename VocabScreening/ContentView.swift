import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FlashcardView()
                .tabItem { Label("Học", systemImage: "rectangle.on.rectangle") }
            StatsView()
                .tabItem { Label("Thống kê", systemImage: "chart.bar") }
            SettingsView()
                .tabItem { Label("Cài đặt", systemImage: "gearshape") }
        }
    }
}
