import Foundation

/// Leitner-style spaced-repetition state for a single word.
struct WordProgress: Codable {
    var wordId: String
    var box: Int = 1
    var lastReviewed: Date?
    var nextDueDate: Date
    var correctStreak: Int = 0
    var totalReviews: Int = 0
}
