import Foundation

/// Builds a list of (hour, word) entries ahead of time so the Lock Screen /
/// Home Screen widgets can rotate the word every hour from a single
/// WidgetKit timeline, instead of depending on iOS's unreliable background
/// refresh budget.
enum ScheduleGenerator {
    static let newWordsPerDay = 8

    @discardableResult
    static func generateNextHours(count: Int = 24, from startDate: Date = Date()) -> [SharedStore.ScheduleEntry] {
        var progress = SharedStore.loadProgress()
        let allWords = WordBank.shared
        guard !allWords.isEmpty else { return [] }

        let calendar = Calendar.current
        let startHour = calendar.date(bySetting: .minute, value: 0, of: startDate) ?? startDate

        var entries: [SharedStore.ScheduleEntry] = []
        var newWordsIntroduced = 0
        var usedThisRun = Set<String>()

        for i in 0..<count {
            let slotDate = calendar.date(byAdding: .hour, value: i, to: startHour) ?? startHour

            let dueWords = allWords
                .filter { word in
                    guard let p = progress[word.id] else { return false }
                    return p.nextDueDate <= slotDate && !usedThisRun.contains(word.id)
                }
                .sorted {
                    (progress[$0.id]?.nextDueDate ?? .distantFuture)
                        < (progress[$1.id]?.nextDueDate ?? .distantFuture)
                }

            let chosen: Word
            if let due = dueWords.first {
                chosen = due
            } else if newWordsIntroduced < newWordsPerDay,
                      let newWord = allWords.first(where: { progress[$0.id] == nil && !usedThisRun.contains($0.id) }) {
                chosen = newWord
                newWordsIntroduced += 1
            } else if let reviewWord = allWords.first(where: { progress[$0.id] != nil && !usedThisRun.contains($0.id) }) {
                // Re-show an already-introduced word ahead of its due date
                // rather than introducing another brand-new one — this is
                // what actually keeps the "8 new words/day" cap meaningful.
                chosen = reviewWord
            } else if let fallback = allWords.filter({ !usedThisRun.contains($0.id) }).randomElement() {
                chosen = fallback
            } else {
                chosen = allWords[i % allWords.count]
            }

            if progress[chosen.id] == nil {
                progress[chosen.id] = WordProgress(wordId: chosen.id, box: 1, nextDueDate: slotDate)
            }
            usedThisRun.insert(chosen.id)
            entries.append(SharedStore.ScheduleEntry(date: slotDate, wordId: chosen.id))
        }

        SharedStore.saveProgress(progress)
        SharedStore.saveSchedule(entries)
        return entries
    }
}
