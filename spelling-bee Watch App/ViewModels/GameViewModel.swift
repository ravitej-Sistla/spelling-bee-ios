//
//  GameViewModel.swift
//  spelling-bee Watch App
//
//  Manages gameplay state, word progression, and scoring.
//

import Foundation
import SwiftUI

enum GamePhase {
    case presenting      // Word is being presented
    case spelling        // User is typing/dictating spelling
    case feedback        // Showing correct/incorrect feedback
    case levelComplete   // Level completed successfully
}

enum FeedbackType {
    case correct
    case incorrect
}

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published State
    @Published var phase: GamePhase = .presenting
    @Published var session: GameSession?
    @Published var feedbackType: FeedbackType?
    @Published var showRetryOption = false
    @Published var userSpelling = ""

    // MARK: - Services
    private let speechService = SpeechService.shared
    private let wordBank = WordBankService.shared

    // MARK: - Computed Properties
    var currentWord: Word? {
        session?.currentWord
    }

    var correctCount: Int {
        session?.correctCount ?? 0
    }

    var progress: Double {
        session?.progress ?? 0
    }

    var isLevelComplete: Bool {
        session?.isComplete ?? false
    }

    // MARK: - Game Flow

    /// Starts a new game session for a level
    func startLevel(level: Int, grade: Int) {
        let words = wordBank.getWords(grade: grade, level: level, count: 15)
        session = GameSession(level: level, grade: grade, words: words)
        phase = .presenting
        presentCurrentWord()
    }

    /// Presents the current word via TTS
    func presentCurrentWord() {
        guard let word = currentWord else {
            checkLevelCompletion()
            return
        }

        phase = .presenting
        speechService.speakWord(word.text)
    }

    /// Repeats the current word
    func repeatWord() {
        guard let word = currentWord else { return }
        speechService.speakWord(word.text)
    }

    /// Starts spelling input mode
    func startSpelling() {
        phase = .spelling
        userSpelling = ""
    }

    /// Submits the current spelling attempt
    func submitSpelling() {
        guard let word = currentWord else { return }

        // Check if spelling is correct
        if SpeechService.validateSpelling(userInput: userSpelling, correctWord: word.text) {
            handleCorrectAnswer()
        } else {
            handleIncorrectAnswer()
        }
    }

    /// Handles a correct spelling
    private func handleCorrectAnswer() {
        session?.markCorrect()
        feedbackType = .correct
        phase = .feedback

        // Speak encouraging feedback
        let encouragements = [
            "Great job!",
            "Excellent!",
            "You got it!",
            "Perfect!",
            "Amazing!",
            "Wonderful!"
        ]
        speechService.speakFeedback(encouragements.randomElement() ?? "Correct!")

        // Auto-advance after delay
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            await MainActor.run {
                self.advanceToNextWord()
            }
        }
    }

    /// Handles an incorrect spelling
    private func handleIncorrectAnswer() {
        feedbackType = .incorrect
        phase = .feedback
        showRetryOption = true

        // Speak encouraging feedback
        let encouragements = [
            "Nice try!",
            "Almost there!",
            "Keep trying!",
            "Don't give up!"
        ]
        speechService.speakFeedback(encouragements.randomElement() ?? "Try again!")
    }

    /// Retry the current word
    func retry() {
        showRetryOption = false
        userSpelling = ""
        phase = .presenting
        presentCurrentWord()
    }

    /// Give up on current word and show correct spelling
    func giveUp() {
        guard let word = currentWord else { return }

        showRetryOption = false

        // Spell out the correct word
        speechService.speakFeedback("The correct spelling is")
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                self.speechService.spellWord(word.text)
            }
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                self.session?.markIncorrect()
                self.advanceToNextWord()
            }
        }
    }

    /// Advances to the next word or completes level
    private func advanceToNextWord() {
        showRetryOption = false
        feedbackType = nil
        userSpelling = ""

        if isLevelComplete {
            phase = .levelComplete
            speechService.speakFeedback("Congratulations! You completed the level!")
        } else if currentWord != nil {
            phase = .presenting
            presentCurrentWord()
        } else {
            // No more words but not enough correct - reload
            phase = .levelComplete
        }
    }

    /// Checks if level is complete
    private func checkLevelCompletion() {
        if isLevelComplete {
            phase = .levelComplete
        }
    }

    /// Gets the level number for completion
    var completedLevel: Int {
        session?.level ?? 0
    }

    /// Cleans up when leaving game
    func cleanup() {
        speechService.stopSpeaking()
    }
}
