import Foundation

/// Reads/writes state shared between the main app and the widget extension
/// via the App Group container. Update `appGroupId` below if you change the
/// group identifier in project.yml.
enum SharedStore {
    static let appGroupId = "group.com.nghixn.vocabscreening"

    struct ScheduleEntry: Codable {
        let date: Date
        let wordId: String
    }

    private static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)
    }

    private static var progressURL: URL? {
        containerURL?.appendingPathComponent("word_progress.json")
    }

    private static var scheduleURL: URL? {
        containerURL?.appendingPathComponent("hourly_schedule.json")
    }

    private static var streakURL: URL? {
        containerURL?.appendingPathComponent("streak.json")
    }

    private static var selectedLevelsURL: URL? {
        containerURL?.appendingPathComponent("selected_levels.json")
    }

    private static let defaultLevels = Set(VocabLevel.allCases.map { $0.rawValue })

    // MARK: - Per-word SRS progress

    static func loadProgress() -> [String: WordProgress] {
        guard let url = progressURL,
              let data = try? Data(contentsOf: url),
              let dict = try? JSONDecoder().decode([String: WordProgress].self, from: data) else {
            return [:]
        }
        return dict
    }

    static func saveProgress(_ progress: [String: WordProgress]) {
        guard let url = progressURL,
              let data = try? JSONEncoder().encode(progress) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Precomputed hourly word schedule (read by the widget timeline)

    static func loadSchedule() -> [ScheduleEntry] {
        guard let url = scheduleURL,
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([ScheduleEntry].self, from: data) else {
            return []
        }
        return entries
    }

    static func saveSchedule(_ entries: [ScheduleEntry]) {
        guard let url = scheduleURL,
              let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Daily learning streak

    static func loadStreak() -> StreakData {
        guard let url = streakURL,
              let data = try? Data(contentsOf: url),
              let streak = try? JSONDecoder().decode(StreakData.self, from: data) else {
            return StreakData()
        }
        return streak
    }

    static func saveStreak(_ streak: StreakData) {
        guard let url = streakURL,
              let data = try? JSONEncoder().encode(streak) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Which CEFR levels to draw words from

    /// Defaults to every level (current behavior) until the user picks
    /// specific ones in Settings. An empty stored set (shouldn't happen,
    /// but cheap to guard) also falls back to the default rather than
    /// leaving the word pool empty.
    static func loadSelectedLevels() -> Set<String> {
        guard let url = selectedLevelsURL,
              let data = try? Data(contentsOf: url),
              let levels = try? JSONDecoder().decode(Set<String>.self, from: data),
              !levels.isEmpty else {
            return defaultLevels
        }
        return levels
    }

    static func saveSelectedLevels(_ levels: Set<String>) {
        guard let url = selectedLevelsURL,
              let data = try? JSONEncoder().encode(levels) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
