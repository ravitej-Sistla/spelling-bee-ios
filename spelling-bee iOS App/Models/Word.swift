//
//  Word.swift
//  spelling-bee iOS App
//
//  Word model and game session tracking.
//

import Foundation

struct Word: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let difficulty: Int
}

class GameSession {
    let level: Int
    let grade: Int
    private(set) var words: [Word]
    private(set) var currentIndex: Int = 0
    private(set) var correctCount: Int = 0
    private(set) var incorrectCount: Int = 0

    let requiredCorrect = 10

    init(level: Int, grade: Int, words: [Word]) {
        self.level = level
        self.grade = grade
        self.words = words
    }

    var currentWord: Word? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }

    var isComplete: Bool {
        correctCount >= requiredCorrect
    }

    var progress: Double {
        Double(correctCount) / Double(requiredCorrect)
    }

    func markCorrect() {
        correctCount += 1
        currentIndex += 1
    }

    func markIncorrect() {
        incorrectCount += 1
        currentIndex += 1
    }
}
