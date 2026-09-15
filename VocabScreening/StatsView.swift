import SwiftUI

struct StatsView: View {
    @State private var progress: [String: WordProgress] = [:]

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
            .onAppear { progress = SharedStore.loadProgress() }
        }
    }
}
