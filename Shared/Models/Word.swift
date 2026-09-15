import Foundation

struct Word: Codable, Identifiable, Hashable {
    let id: String
    let text: String
    let ipa: String
    let cefr: String
    let meaningVI: String
    let example: String
    let exampleVI: String
}
