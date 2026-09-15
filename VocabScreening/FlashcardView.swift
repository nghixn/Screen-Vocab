import SwiftUI

/// Active-recall flashcard: the user sees the word first, tries to recall the
/// meaning, then taps to reveal it before marking Remembered / Forgot. This
/// feeds the SRS engine, which is what makes the hourly word rotation get
/// smarter over time instead of staying purely random.
struct FlashcardView: View {
    @State private var currentWord: Word?
    @State private var revealed = false

    var body: some View {
        VStack(spacing: 24) {
            if let word = currentWord {
                VStack(spacing: 12) {
                    Text(word.text).font(.largeTitle).bold()
                    Text(word.ipa).font(.title3).foregroundStyle(.secondary)

                    if revealed {
                        Divider()
                        Text(word.meaningVI).font(.title3)
                        Text(word.example).font(.body).italic()
                        Text(word.exampleVI).font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .onTapGesture { withAnimation { revealed.toggle() } }
                .padding(.horizontal)

                if revealed {
                    HStack(spacing: 16) {
                        Button("Chưa nhớ") { answer(remembered: false) }
                            .buttonStyle(.bordered)
                        Button("Đã nhớ") { answer(remembered: true) }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    Text("Chạm vào thẻ để xem nghĩa")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .onAppear(perform: loadCurrentWord)
    }

    private func loadCurrentWord() {
        let schedule = SharedStore.loadSchedule().sorted { $0.date < $1.date }
        let now = Date()
        if let entry = schedule.last(where: { $0.date <= now }) ?? schedule.first {
            currentWord = WordBank.word(byId: entry.wordId)
        } else {
            currentWord = WordBank.shared.randomElement()
        }
        revealed = false
    }

    private func answer(remembered: Bool) {
        guard let word = currentWord else { return }
        var progress = SharedStore.loadProgress()
        let existing = progress[word.id] ?? WordProgress(wordId: word.id, box: 1, nextDueDate: Date())
        progress[word.id] = SRSEngine.recordResult(progress: existing, remembered: remembered)
        SharedStore.saveProgress(progress)
        AppScheduler.regenerateAndReload()
        loadCurrentWord()
    }
}
