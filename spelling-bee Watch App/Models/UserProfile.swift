//
//  UserProfile.swift
//  spelling-bee Watch App
//

import Foundation

struct UserProfile: Codable, Equatable {
    var name: String
    var grade: Int // 1-7
    var completedLevels: Set<Int> // Level numbers that are completed
    var currentLevel: Int // Highest unlocked level (1-50)

    init(name: String, grade: Int) {
        self.name = name
        self.grade = max(1, min(7, grade))
        self.completedLevels = []
        self.currentLevel = 1
    }

    mutating func completeLevel(_ level: Int) {
        completedLevels.insert(level)
        if level == currentLevel && currentLevel < 50 {
            currentLevel = level + 1
        }
    }

    func isLevelUnlocked(_ level: Int) -> Bool {
        return level <= currentLevel
    }

    func isLevelCompleted(_ level: Int) -> Bool {
        return completedLevels.contains(level)
    }
}
