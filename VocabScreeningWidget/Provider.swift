import WidgetKit

struct WordEntry: TimelineEntry {
    let date: Date
    let word: Word?
}

/// Instead of relying on iOS's unreliable background-refresh budget to swap
/// the word every hour, this provider pre-computes ~24 hourly entries in one
/// timeline. iOS then displays whichever entry's `date` has arrived, so the
/// hourly rotation is accurate even though the widget process itself is only
/// woken up roughly once a day to build the next batch.
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), word: WordBank.shared.first)
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        completion(WordEntry(date: Date(), word: WordBank.shared.first))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let now = Date()
        var schedule = SharedStore.loadSchedule()

        if schedule.filter({ $0.date >= now }).count < 3 {
            schedule = ScheduleGenerator.generateNextHours(count: 24, from: now)
        }

        let entries: [WordEntry] = schedule
            .filter { $0.date >= now.addingTimeInterval(-3600) }
            .sorted { $0.date < $1.date }
            .map { WordEntry(date: $0.date, word: WordBank.word(byId: $0.wordId)) }

        let refreshDate = Calendar.current.date(byAdding: .hour, value: 20, to: now) ?? now.addingTimeInterval(20 * 3600)
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}
