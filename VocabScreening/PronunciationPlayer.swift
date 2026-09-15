import AVFoundation

/// Plays real spoken pronunciation using iOS's on-device text-to-speech.
/// This is only used from the main app — WidgetKit extensions (Lock Screen /
/// Home Screen widgets) cannot play audio, so tapping the widget just opens
/// the app, which is already showing the same word.
final class PronunciationPlayer: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func speak(_ text: String, rate: Float = AVSpeechUtteranceDefaultSpeechRate * 0.85) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB") ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = rate
        synthesizer.speak(utterance)
    }
}
