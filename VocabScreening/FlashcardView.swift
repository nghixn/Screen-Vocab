import AVFoundation
import SwiftUI

/// Multiple-choice quiz: the user picks the correct meaning out of 4 options
/// instead of self-reporting "Remembered/Forgot" — a self-report is easy to
/// fudge without noticing, while an actual quiz answer is an objective
/// signal that feeds the SRS engine.
struct FlashcardView: View {
    @State private var currentWord: Word?
    @State private var choices: [Word] = []
    @State private var selectedChoice: Word?
    @StateObject private var player = PronunciationPlayer()

    private var streak: StreakData {
        StreakTracker.currentStatus()
    }

    private var isAnswered: Bool { selectedChoice != nil }

    var body: some View {
        VStack(spacing: 20) {
            if streak.currentStreak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").foregroundStyle(.orange)
                    Text("\(streak.currentStreak) ngày liên tiếp")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            if let word = currentWord {
                VStack(spacing: 12) {
                    Text(word.text).font(.largeTitle).bold()

                    HStack(spacing: 8) {
                        Text(word.ipa).font(.title3).foregroundStyle(.secondary)
                        Button {
                            player.speak(word.text)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Nghe phát âm")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                Text("Từ này có nghĩa là gì?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    ForEach(choices) { choice in
                        Button {
                            submitAnswer(choice)
                        } label: {
                            HStack {
                                Text(choice.meaningVI)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if isAnswered && choice.id == word.id {
                                    Image(systemName: "checkmark.circle.fill")
                                } else if isAnswered && choice.id == selectedChoice?.id {
                                    Image(systemName: "xmark.circle.fill")
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(choiceBackground(for: choice, correct: word), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .disabled(isAnswered)
                    }
                }
                .padding(.horizontal)

                if isAnswered {
                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            Text(word.example).font(.body).italic()
                            Button {
                                player.speak(word.example, rate: AVSpeechUtteranceDefaultSpeechRate * 0.95)
                            } label: {
                                Image(systemName: "speaker.wave.2")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Nghe ví dụ")
                        }
                        Text(word.exampleVI).font(.footnote).foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    Button("Từ tiếp theo") { loadCurrentWord() }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .onAppear(perform: loadCurrentWord)
    }

    private func choiceBackground(for choice: Word, correct: Word) -> Color {
        guard isAnswered else { return Color.secondary.opacity(0.1) }
        if choice.id == correct.id {
            return Color.green.opacity(0.25)
        } else if choice.id == selectedChoice?.id {
            return Color.red.opacity(0.25)
        }
        return Color.secondary.opacity(0.1)
    }

    private func loadCurrentWord() {
        let schedule = SharedStore.loadSchedule().sorted { $0.date < $1.date }
        let now = Date()
        let nextWord: Word?
        if let entry = schedule.last(where: { $0.date <= now }) ?? schedule.first {
            nextWord = WordBank.word(byId: entry.wordId)
        } else {
            nextWord = WordBank.shared.randomElement()
        }

        currentWord = nextWord
        selectedChoice = nil
        choices = nextWord.map(makeChoices) ?? []
    }

    private func makeChoices(for word: Word) -> [Word] {
        let distractorPool = WordBank.shared.filter { $0.id != word.id && $0.meaningVI != word.meaningVI }
        let distractors = Array(distractorPool.shuffled().prefix(3))
        var all = distractors + [word]
        all.shuffle()
        return all
    }

    private func submitAnswer(_ choice: Word) {
        guard !isAnswered, let word = currentWord else { return }
        selectedChoice = choice
        let remembered = choice.id == word.id

        var progress = SharedStore.loadProgress()
        let existing = progress[word.id] ?? WordProgress(wordId: word.id, box: 1, nextDueDate: Date())
        progress[word.id] = SRSEngine.recordResult(progress: existing, remembered: remembered)
        SharedStore.saveProgress(progress)
        StreakTracker.recordActivity()
        AppScheduler.regenerateAndReload()
    }
}
