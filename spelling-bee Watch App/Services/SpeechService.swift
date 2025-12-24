//
//  SpeechService.swift
//  spelling-bee Watch App
//
//  Handles text-to-speech using AVSpeechSynthesizer.
//  Note: Speech recognition (Speech framework) is not available on watchOS.
//  User input is handled via SwiftUI's native dictation in TextField.
//

import Foundation
import AVFoundation

@MainActor
class SpeechService: NSObject, ObservableObject {
    static let shared = SpeechService()

    // MARK: - Published State
    @Published var isSpeaking = false

    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()

    // MARK: - Initialization
    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Text-to-Speech

    /// Speaks a word clearly for spelling practice
    func speakWord(_ word: String) {
        stopSpeaking()

        let utterance = AVSpeechUtterance(string: word)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8 // Slightly slower for kids
        utterance.pitchMultiplier = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Spells out a word letter by letter
    func spellWord(_ word: String) {
        stopSpeaking()

        let letters = word.uppercased().map { String($0) }.joined(separator: ", ")
        let utterance = AVSpeechUtterance(string: letters)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.6 // Slower for letter spelling
        utterance.pitchMultiplier = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Speaks feedback messages
    func speakFeedback(_ message: String) {
        stopSpeaking()

        let utterance = AVSpeechUtterance(string: message)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.1 // Slightly higher pitch for encouragement
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}

// MARK: - Spelling Validation Helper
extension SpeechService {
    /// Validates user's typed/dictated spelling against the correct word
    /// Handles common variations and normalizes input
    static func validateSpelling(userInput: String, correctWord: String) -> Bool {
        // Normalize both strings
        let normalizedInput = userInput
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

        let normalizedCorrect = correctWord.lowercased()

        return normalizedInput == normalizedCorrect
    }
}
