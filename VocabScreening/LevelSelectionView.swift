import SwiftUI

/// Lets the user pick which CEFR level(s) to draw words from, with a short
/// "I can..." self-assessment description per level so they can tell which
/// one actually fits — a bare "A2/B1/B2" label isn't enough for most people
/// to self-rate correctly.
struct LevelSelectionView: View {
    @State private var selectedLevels: Set<String> = SharedStore.loadSelectedLevels()

    var body: some View {
        List {
            Section {
                ForEach(VocabLevel.allCases) { level in
                    Button {
                        toggle(level)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.title).font(.headline)
                                Text(level.selfAssessment)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: selectedLevels.contains(level.rawValue) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedLevels.contains(level.rawValue) ? Color.accentColor : Color.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Chọn cấp độ phù hợp với bạn")
            } footer: {
                Text("Có thể chọn nhiều cấp độ cùng lúc. Phải giữ lại ít nhất một cấp độ.")
            }
        }
        .navigationTitle("Cấp độ từ vựng")
    }

    private func toggle(_ level: VocabLevel) {
        var updated = selectedLevels
        if updated.contains(level.rawValue) {
            guard updated.count > 1 else { return } // always keep at least one level selected
            updated.remove(level.rawValue)
        } else {
            updated.insert(level.rawValue)
        }
        selectedLevels = updated
        SharedStore.saveSelectedLevels(updated)
        AppScheduler.regenerateAndReload()
    }
}
