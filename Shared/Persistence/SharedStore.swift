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
}
