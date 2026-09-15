import Foundation
import WidgetKit

enum AppScheduler {
    /// Called on app launch; only regenerates the schedule when it's close to running out.
    static func refreshIfNeeded() {
        let schedule = SharedStore.loadSchedule()
        let now = Date()
        if schedule.filter({ $0.date >= now }).count < 3 {
            regenerateAndReload()
        }
    }

    /// Called after the user reviews a word, since its box (and thus future due dates) changed.
    static func regenerateAndReload() {
        ScheduleGenerator.generateNextHours(count: 24, from: Date())
        WidgetCenter.shared.reloadAllTimelines()
    }
}
