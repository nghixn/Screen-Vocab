import SwiftUI

struct StatsView: View {
    // Read fresh from disk on every body evaluation (including tab
    // switches) instead of caching in @State — caching + .onAppear was
    // unreliable here since this view sits inside a NavigationStack inside
    // a TabView, where onAppear doesn't always refire on tab reselection.
    private var progress: [String: WordProgress] {
        SharedStore.loadProgress()
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Tổng quan") {
                    LabeledContent("Tổng số từ", value: "\(WordBank.shared.count)")
                    LabeledContent("Đã học", value: "\(progress.count)")
                    LabeledContent("Đã thuộc (box ≥ 5)", value: "\(progress.values.filter { $0.box >= 5 }.count)")
                }
                Section("Theo mức độ nhớ (box)") {
                    ForEach(1...6, id: \.self) { box in
                        LabeledContent("Box \(box)", value: "\(progress.values.filter { $0.box == box }.count)")
                    }
                }
            }
            .navigationTitle("Thống kê")
        }
    }
}
