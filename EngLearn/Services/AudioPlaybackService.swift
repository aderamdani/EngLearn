import Foundation
import AVFoundation
import SwiftUI
import OSLog

@MainActor
final class AudioPlaybackService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isPlaying = false
    
    // We fetch rate from AppStorage but manage it via properties for simplicity here
    // In a full implementation, we'd listen to AppStorage changes
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func play(text: String, rate: Double = AppConstants.Limits.ttsNormalRate) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        // AVSpeechUtterance rates are 0.0 to 1.0, with default ~0.5
        // Convert the rate parameter to fit reasonably
        utterance.rate = Float(rate)
        
        Log.audio.info("Playing audio: \(text)")
        synthesizer.speak(utterance)
        isPlaying = true
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isPlaying = false
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }
}
