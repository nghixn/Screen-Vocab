import Foundation

struct StreakData: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActiveDay: Date?
}
