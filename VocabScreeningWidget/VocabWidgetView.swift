import SwiftUI
import WidgetKit

struct VocabWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WordEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            if let word = entry.word {
                Text("\(word.text) · \(word.ipa)")
            } else {
                Text("Vocab Screening")
            }
        case .accessoryRectangular:
            LockScreenRectangularView(word: entry.word)
        default:
            HomeScreenMediumView(word: entry.word)
        }
    }
}

/// Lock Screen widget: small, so it only fits the word + pronunciation —
/// exactly what the user glances at each time they wake the phone.
private struct LockScreenRectangularView: View {
    let word: Word?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let word {
                Text(word.text).font(.headline)
                Text(word.ipa).font(.caption2)
            } else {
                Text("Vocab Screening")
            }
        }
    }
}

/// Home Screen widget: bigger, so it can show meaning + example too.
private struct HomeScreenMediumView: View {
    let word: Word?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let word {
                HStack(alignment: .firstTextBaseline) {
                    Text(word.text).font(.title2).bold()
                    Text(word.ipa).font(.subheadline).foregroundStyle(.secondary)
                }
                Text(word.meaningVI).font(.body)
                Text(word.example).font(.footnote).italic().foregroundStyle(.secondary)
            } else {
                Text("Vocab Screening")
            }
        }
        .padding(4)
    }
}
