//
//  Word.swift
//  spelling-bee Watch App
//

import Foundation

struct Word: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let difficulty: Int // 1-10 scale

    var letters: [String] {
        text.uppercased().map { String($0) }
    }

    func matches(spokenLetters: String) -> Bool {
        // Normalize: remove spaces, punctuation, lowercase
        let normalized = spokenLetters
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")

        return normalized == text.lowercased()
    }
}

// MARK: - Game Session Tracking
struct GameSession {
    let level: Int
    let grade: Int
    var words: [Word]
    var currentWordIndex: Int = 0
    var correctCount: Int = 0
    var incorrectWords: [Word] = []

    var currentWord: Word? {
        guard currentWordIndex < words.count else { return nil }
        return words[currentWordIndex]
    }

    var isComplete: Bool {
        correctCount >= 10
    }

    var progress: Double {
        Double(correctCount) / 10.0
    }

    mutating func markCorrect() {
        correctCount += 1
        currentWordIndex += 1
    }

    mutating func markIncorrect() {
        if let word = currentWord {
            incorrectWords.append(word)
        }
        currentWordIndex += 1
    }

    mutating func skipWord() {
        currentWordIndex += 1
    }
}
