import SwiftUI
import AVFoundation

struct PlayLearningCardScreen: View {
    // Reuse existing model for artwork/title, but we'll play a single audio file
    @State var model: LearningCardModel

    // New: pass in the audio file name (without or with extension). We'll resolve mp3 in bundle.
    var audioFileName: String? = nil

    // Playback state
    @State private var isPlaying: Bool = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0

    // AVAudioPlayer for mp3 playback
    @State private var audioPlayer: AVAudioPlayer?

    // Timer for updating progress
    @State private var displayLink: CADisplayLink? = nil

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0), 1)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Podcast artwork
                Image(model.imageName)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 8)
                    .padding(.top, 24)

                // Title & description
                VStack(spacing: 8) {
                    Text(model.title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    if !model.description.isEmpty {
                        Text(model.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                // Time labels
                HStack {
                    Text(currentTime.mmss)
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(duration.mmss)
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Progress / seek
                Slider(value: Binding(
                    get: { progress },
                    set: { newValue in
                        seek(toProgress: newValue)
                    }
                ), in: 0...1)
                .tint(.red)
                .padding(.horizontal)

                // Transport controls
                HStack(spacing: 60) {
                    Button {
                        skip(seconds: -15)
                    } label: {
                        VStack {
                            Image(systemName: "gobackward.15")
                                .font(.title2)
                            Text("-15s").font(.caption2)
                        }
                        .foregroundColor(.primary)
                    }

                    Button {
                        togglePlayPause()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(Circle().fill(Color.red))
                    }

                    Button {
                        skip(seconds: 30)
                    } label: {
                        VStack {
                            Image(systemName: "goforward.30")
                                .font(.title2)
                            Text("+30s").font(.caption2)
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding(.vertical)

                // Remove transcript section as requested
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.red, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        }
        .onAppear {
            configureAudioSession()
            prepareAndLoadAudio()
            startDisplayLink()
        }
        .onDisappear {
            stopPlayback()
            stopDisplayLink()
        }
    }
}

// MARK: - Audio setup & controls
private extension PlayLearningCardScreen {
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.allowBluetooth, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession error: \(error)")
        }
    }

    func prepareAndLoadAudio() {
        // Determine file name: prefer provided audioFileName, else infer from model.title if it matches provided assets
        let fileName: String
        if let explicit = audioFileName, !explicit.isEmpty {
            fileName = explicit
        } else {
            // Fallback: map some known titles to files
            let lower = model.title.lowercased()
            if lower.contains("taming") {
                fileName = "Taming_OpenShift"
            } else {
                fileName = "OpenShift"
            }
        }

        // Accept either with or without extension
        let baseName = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension.isEmpty ? "mp3" : (fileName as NSString).pathExtension

        guard let url = Bundle.main.url(forResource: baseName, withExtension: ext) else {
            print("Audio file not found: \(baseName).\(ext)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayer = player
            duration = player.duration
            currentTime = 0
        } catch {
            print("Failed to init AVAudioPlayer: \(error)")
        }
    }

    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        currentTime = 0
    }

    func skip(seconds: TimeInterval) {
        guard let player = audioPlayer else { return }
        let newTime = min(max(player.currentTime + seconds, 0), player.duration)
        player.currentTime = newTime
        currentTime = newTime
        if isPlaying { player.play() }
    }

    func seek(toProgress newValue: Double) {
        guard let player = audioPlayer, player.duration > 0 else { return }
        let clamped = min(max(newValue, 0), 1)
        let newTime = clamped * player.duration
        player.currentTime = newTime
        currentTime = newTime
        if isPlaying { player.play() }
    }
}

// MARK: - Display link (progress updates)
private extension PlayLearningCardScreen {
    func startDisplayLink() {
        let link = CADisplayLink(target: DisplayLinkProxy { [weak audioPlayer] in
            guard let player = audioPlayer else { return }
            self.currentTime = player.currentTime
            self.duration = player.duration
            if player.currentTime >= player.duration {
                self.isPlaying = false
            }
        }, selector: #selector(DisplayLinkProxy.tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

private final class DisplayLinkProxy: NSObject {
    let action: () -> Void
    init(_ action: @escaping () -> Void) { self.action = action }
    @objc func tick() { action() }
}

private extension TimeInterval {
    var mmss: String {
        let total = Int(self.rounded())
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PlayLearningCardScreen(
            model: LearningCardModel(id: UUID(), title: "OpenShift", description: "A podcast episode about OpenShift.", imageName: "", learnCards: []),
            audioFileName: "OpenShift.mp3"
        )
    }
}
