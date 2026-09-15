import Foundation

enum WordBank {
    static let shared: [Word] = load()

    static func word(byId id: String) -> Word? {
        shared.first { $0.id == id }
    }

    private static func load() -> [Word] {
        guard let url = Bundle.main.url(forResource: "wordbank", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let words = try? JSONDecoder().decode([Word].self, from: data) else {
            return []
        }
        return words
    }
}
