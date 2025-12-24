//
//  GameViewModel.swift
//  spelling-bee iOS App
//
//  Manages gameplay state, word progression, and scoring.
//

import Foundation
import SwiftUI

enum GamePhase {
    case presenting
    case spelling
    case feedback
    case levelComplete
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

    func startLevel(level: Int, grade: Int) {
        let words = wordBank.getWords(grade: grade, level: level, count: 15)
        session = GameSession(level: level, grade: grade, words: words)
        phase = .presenting
        presentCurrentWord()
    }

    func presentCurrentWord() {
        guard let word = currentWord else {
            checkLevelCompletion()
            return
        }

        phase = .presenting
        speechService.speakWord(word.text)
    }

    func repeatWord() {
        guard let word = currentWord else { return }
        speechService.speakWord(word.text)
    }

    func startSpelling() {
        phase = .spelling
        userSpelling = ""
    }

    func submitSpelling() {
        guard let word = currentWord else { return }

        if SpeechService.validateSpelling(userInput: userSpelling, correctWord: word.text) {
            handleCorrectAnswer()
        } else {
            handleIncorrectAnswer()
        }
    }

    private func handleCorrectAnswer() {
        session?.markCorrect()
        feedbackType = .correct
        phase = .feedback

        let encouragements = [
            "Great job!",
            "Excellent!",
            "You got it!",
            "Perfect!",
            "Amazing!",
            "Wonderful!"
        ]
        speechService.speakFeedback(encouragements.randomElement() ?? "Correct!")

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                self.advanceToNextWord()
            }
        }
    }

    private func handleIncorrectAnswer() {
        feedbackType = .incorrect
        phase = .feedback
        showRetryOption = true

        let encouragements = [
            "Nice try!",
            "Almost there!",
            "Keep trying!",
            "Don't give up!"
        ]
        speechService.speakFeedback(encouragements.randomElement() ?? "Try again!")
    }

    func retry() {
        showRetryOption = false
        userSpelling = ""
        phase = .presenting
        presentCurrentWord()
    }

    func giveUp() {
        guard let word = currentWord else { return }

        showRetryOption = false

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
            phase = .levelComplete
        }
    }

    private func checkLevelCompletion() {
        if isLevelComplete {
            phase = .levelComplete
        }
    }

    var completedLevel: Int {
        session?.level ?? 0
    }

    func cleanup() {
        speechService.stopSpeaking()
        speechService.stopListening()
    }
}
