import SwiftUI
import AVFoundation

struct PlayLearningCardScreen: View {
    // Expect a model that contains multiple learnCard to play
    @State var model: LearningCardModel

    // Playback state
    @State private var isPlaying: Bool = false
    @State private var currentIndex: Int = 0 {
        didSet {
            print("currentIndex: \(currentIndex)")
        }
    }
    @State private var spokenIndices: Set<Int> = []
    @State private var speechSynth: AVSpeechSynthesizer = AVSpeechSynthesizer()
    @State private var speechDelegate: SpeechDelegate? = nil
    @State private var utteranceProgress: Double = 0 // 0..1 progress within current card
    
    @State private var elapsedSeconds: Double = 0
    @State private var totalSeconds: Double = 0

    // Derived progress based on how many learnCard have been spoken
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(max(elapsedSeconds / totalSeconds, 0), 1)
    }

    private var currentCard: LearnCard? {
        guard model.learnCards.indices.contains(currentIndex) else { return nil }
        return model.learnCards[currentIndex]
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Image in rounded rectangle container
                Image(model.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding()

                // Title centered, bold, slightly larger font
                Text(model.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Subtitle line shows how many learnCard and progress count
                Text("Episode • \(model.learnCards.count) Cards")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Progress row
                HStack {
                    Image(systemName: "gauge")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(TimeInterval(elapsedSeconds).mmss) / \(TimeInterval(totalSeconds).mmss)")
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                ProgressView(value: progress, total: 1)
                    .tint(.red)
                    .padding(.horizontal)

                // Transport controls
                HStack(spacing: 60) {
                    Button {
                        stepBackward()
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Button {
                        togglePlayPause()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.red))
                    }
                    Button {
                        stepForward()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical)

                // Transcript section (show current card content and upcoming)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcript")
                        .font(.headline)
                        .padding(.bottom, 4)

                    if model.learnCards.isEmpty {
                        Text("No content available.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(model.learnCards.indices, id: \.self) { idx in
                            let text = model.learnCards[idx].content
                            Text(text)
                                .font(.body)
                                .foregroundColor(color(for: idx))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Now playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.red, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        }
        .onAppear {
            configureSpeech()
            recalculateTotalDuration()
        }
        .onDisappear { stopSpeaking() }
    }
}

// MARK: - Playback helpers
private extension PlayLearningCardScreen {
    func configureSpeech() {
        let delegate = SpeechDelegate(
            onDidFinish: { finished in
                if finished {
                    advanceAfterFinish()
                }
            },
            onWillSpeakRange: { range, fullString in
                let totalLength = max(fullString.count, 1)
                let spokenUpTo = min(range.location + range.length, totalLength)
                utteranceProgress = Double(spokenUpTo) / Double(totalLength)
                refreshElapsed()
            }
        )
        speechDelegate = delegate
        speechSynth.delegate = delegate
        recalculateTotalDuration()
    }

    func togglePlayPause() {
        if isPlaying {
            pauseSpeaking()
            isPlaying = false
        } else {
            if currentIndex == model.learnCards.count - 1 {
                currentIndex = 0
            }
            startSpeakingIfNeeded()
            isPlaying = true
        }
    }

    func startSpeakingIfNeeded() {
        guard let card = currentCard else { return }
        if speechSynth.isPaused {
            speechSynth.continueSpeaking()
            isPlaying = true
            return
        }
        if !speechSynth.isSpeaking {
            utteranceProgress = 0
            refreshElapsed()
            speak(text: card.content)
            isPlaying = true
        }
    }

    func pauseSpeaking() {
        speechSynth.pauseSpeaking(at: .immediate)
    }

    func stopSpeaking() {
        speechSynth.stopSpeaking(at: .immediate)
    }

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
        speechSynth.speak(utterance)
    }

    func advanceAfterFinish() {
        // mark current as spoken
        if model.learnCards.indices.contains(currentIndex) {
            spokenIndices.insert(currentIndex)
        }
        // move to next
        if currentIndex + 1 < model.learnCards.count {
            currentIndex += 1
            utteranceProgress = 0
            refreshElapsed()
            // Automatically continue to the next card if the user was playing
            if isPlaying {
                startSpeakingIfNeeded()
            }
        } else {
            // finished all
            isPlaying = false
        }
    }

    func stepForward() {
        let wasPlaying = isPlaying
        stopSpeaking()
        if currentIndex + 1 < model.learnCards.count {
            currentIndex += 1
            utteranceProgress = 0
            refreshElapsed()
        }
        if wasPlaying {
            startSpeakingIfNeeded()
            isPlaying = true
        }
    }

    func stepBackward() {
        let wasPlaying = isPlaying
        stopSpeaking()
        if currentIndex - 1 >= 0 {
            currentIndex -= 1
            utteranceProgress = 0
            refreshElapsed()
        }
        if wasPlaying {
            startSpeakingIfNeeded()
            isPlaying = true
        }
    }

    func color(for index: Int) -> Color {
        if index == currentIndex { return .red }
        if index < currentIndex { return .secondary}
        return .primary
    }
    
    func recalculateTotalDuration() {
        // Create a temporary utterance to read the rate used
        let tempUtterance = AVSpeechUtterance(string: "")
        // Use the current locale voice if set similarly to speak(_:) for consistency
        tempUtterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
        let rate = tempUtterance.rate
        totalSeconds = model.learnCards.map { $0.content.estimatedSpeechDuration(rate: rate) }.reduce(0, +)
    }
    
    func elapsedTimeForCurrentState() -> Double {
        guard !model.learnCards.isEmpty else { return 0 }
        // Sum durations before currentIndex
        let tempUtterance = AVSpeechUtterance(string: "")
        tempUtterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
        let rate = tempUtterance.rate
        let durations = model.learnCards.map { $0.content.estimatedSpeechDuration(rate: rate) }
        let completed = durations.prefix(currentIndex).reduce(0, +)
        let currentDuration = durations.indices.contains(currentIndex) ? durations[currentIndex] : 0
        return completed + currentDuration * utteranceProgress.clamped(to: 0...1)
    }
    
    func refreshElapsed() {
        // Compute from current state; call this from places where state changes
        elapsedSeconds = elapsedTimeForCurrentState()
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

private extension String {
    /// Rough estimate of speech duration in seconds for a given rate.
    func estimatedSpeechDuration(rate: Float) -> Double {
        // Heuristic: words per minute derived from AVSpeechUtteranceDefaultSpeechRate
        // Convert rate (0.0..1.0 roughly) to words per minute; use a baseline ~180 wpm at default rate.
        let baselineWPM: Double = 180
        let adjustedWPM = max(60.0, min(300.0, Double(rate) * 200 + 80))
        let words = self.split{ $0.isWhitespace || $0.isNewline }.count
        return Double(words) / (adjustedWPM / 60.0)
    }
}

private extension TimeInterval {
    var mmss: String {
        let total = Int(self.rounded())
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - AVSpeechSynthesizerDelegate bridge
private final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let onDidFinish: (Bool) -> Void
    private let onWillSpeakRange: ((NSRange, String) -> Void)?

    init(onDidFinish: @escaping (Bool) -> Void, onWillSpeakRange: ((NSRange, String) -> Void)? = nil) {
        self.onDidFinish = onDidFinish
        self.onWillSpeakRange = onWillSpeakRange
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onDidFinish(true)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        onWillSpeakRange?(characterRange, utterance.speechString)
    }
}

// MARK: - Preview
#Preview {
    
    NavigationStack {
        PlayLearningCardScreen(model: LearningCardModel(id: UUID(),title: "", description: "", imageName: "", learnCards: [LearnCard]()))
    }
}

