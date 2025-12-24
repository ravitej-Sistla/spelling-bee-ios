//
//  WordBankService.swift
//  spelling-bee Watch App
//
//  Word Difficulty Strategy:
//  - Base difficulty = grade level (1-7)
//  - Level adds incremental difficulty (levels 1-50 add 0-5 points)
//  - Combined difficulty range: 1-12
//  - Words are selected from pools matching the target difficulty range
//

import Foundation

class WordBankService {
    static let shared = WordBankService()

    private init() {}

    // MARK: - Difficulty Calculation

    /// Calculates target difficulty based on grade and level
    /// Grade 1 + Level 1 = difficulty 1
    /// Grade 7 + Level 50 = difficulty 12
    func calculateDifficulty(grade: Int, level: Int) -> Int {
        let baseDifficulty = grade
        let levelBonus = (level - 1) / 10 // 0-4 based on level brackets
        return min(12, baseDifficulty + levelBonus)
    }

    /// Gets words for a specific grade and level
    func getWords(grade: Int, level: Int, count: Int = 15) -> [Word] {
        let targetDifficulty = calculateDifficulty(grade: grade, level: level)
        let range = max(1, targetDifficulty - 1)...min(12, targetDifficulty + 1)

        // Filter words within difficulty range
        let eligibleWords = allWords.filter { range.contains($0.difficulty) }

        // Shuffle and take required count
        let shuffled = eligibleWords.shuffled()
        return Array(shuffled.prefix(count))
    }

    // MARK: - Word Bank
    // Difficulty scale: 1-12
    // 1-2: Very simple (CVC words, common sight words)
    // 3-4: Simple (short words, common patterns)
    // 5-6: Moderate (longer words, common spelling patterns)
    // 7-8: Challenging (complex patterns, silent letters)
    // 9-10: Advanced (unusual patterns, longer words)
    // 11-12: Expert (competition-level words)

    private let allWords: [Word] = [
        // DIFFICULTY 1 - Grade 1, Early Levels
        Word(text: "cat", difficulty: 1),
        Word(text: "dog", difficulty: 1),
        Word(text: "sun", difficulty: 1),
        Word(text: "run", difficulty: 1),
        Word(text: "big", difficulty: 1),
        Word(text: "red", difficulty: 1),
        Word(text: "hat", difficulty: 1),
        Word(text: "cup", difficulty: 1),
        Word(text: "bed", difficulty: 1),
        Word(text: "pen", difficulty: 1),
        Word(text: "top", difficulty: 1),
        Word(text: "hop", difficulty: 1),
        Word(text: "box", difficulty: 1),
        Word(text: "fox", difficulty: 1),
        Word(text: "sit", difficulty: 1),

        // DIFFICULTY 2
        Word(text: "play", difficulty: 2),
        Word(text: "jump", difficulty: 2),
        Word(text: "tree", difficulty: 2),
        Word(text: "book", difficulty: 2),
        Word(text: "look", difficulty: 2),
        Word(text: "like", difficulty: 2),
        Word(text: "make", difficulty: 2),
        Word(text: "come", difficulty: 2),
        Word(text: "some", difficulty: 2),
        Word(text: "have", difficulty: 2),
        Word(text: "ball", difficulty: 2),
        Word(text: "call", difficulty: 2),
        Word(text: "fall", difficulty: 2),
        Word(text: "tall", difficulty: 2),
        Word(text: "wall", difficulty: 2),
        Word(text: "fish", difficulty: 2),
        Word(text: "wish", difficulty: 2),
        Word(text: "ship", difficulty: 2),
        Word(text: "shop", difficulty: 2),

        // DIFFICULTY 3
        Word(text: "apple", difficulty: 3),
        Word(text: "happy", difficulty: 3),
        Word(text: "funny", difficulty: 3),
        Word(text: "bunny", difficulty: 3),
        Word(text: "sunny", difficulty: 3),
        Word(text: "water", difficulty: 3),
        Word(text: "after", difficulty: 3),
        Word(text: "under", difficulty: 3),
        Word(text: "never", difficulty: 3),
        Word(text: "seven", difficulty: 3),
        Word(text: "green", difficulty: 3),
        Word(text: "dream", difficulty: 3),
        Word(text: "sleep", difficulty: 3),
        Word(text: "sweet", difficulty: 3),
        Word(text: "clean", difficulty: 3),
        Word(text: "beach", difficulty: 3),
        Word(text: "teach", difficulty: 3),
        Word(text: "reach", difficulty: 3),

        // DIFFICULTY 4
        Word(text: "friend", difficulty: 4),
        Word(text: "school", difficulty: 4),
        Word(text: "people", difficulty: 4),
        Word(text: "family", difficulty: 4),
        Word(text: "purple", difficulty: 4),
        Word(text: "yellow", difficulty: 4),
        Word(text: "orange", difficulty: 4),
        Word(text: "animal", difficulty: 4),
        Word(text: "butterfly", difficulty: 4),
        Word(text: "rainbow", difficulty: 4),
        Word(text: "flower", difficulty: 4),
        Word(text: "garden", difficulty: 4),
        Word(text: "kitchen", difficulty: 4),
        Word(text: "birthday", difficulty: 4),
        Word(text: "morning", difficulty: 4),
        Word(text: "evening", difficulty: 4),
        Word(text: "picture", difficulty: 4),

        // DIFFICULTY 5
        Word(text: "beautiful", difficulty: 5),
        Word(text: "different", difficulty: 5),
        Word(text: "important", difficulty: 5),
        Word(text: "something", difficulty: 5),
        Word(text: "everything", difficulty: 5),
        Word(text: "everyone", difficulty: 5),
        Word(text: "remember", difficulty: 5),
        Word(text: "tomorrow", difficulty: 5),
        Word(text: "together", difficulty: 5),
        Word(text: "favorite", difficulty: 5),
        Word(text: "surprise", difficulty: 5),
        Word(text: "hospital", difficulty: 5),
        Word(text: "chocolate", difficulty: 5),
        Word(text: "celebrate", difficulty: 5),
        Word(text: "adventure", difficulty: 5),

        // DIFFICULTY 6
        Word(text: "environment", difficulty: 6),
        Word(text: "temperature", difficulty: 6),
        Word(text: "experiment", difficulty: 6),
        Word(text: "electricity", difficulty: 6),
        Word(text: "imagination", difficulty: 6),
        Word(text: "celebration", difficulty: 6),
        Word(text: "dictionary", difficulty: 6),
        Word(text: "necessary", difficulty: 6),
        Word(text: "definitely", difficulty: 6),
        Word(text: "especially", difficulty: 6),
        Word(text: "community", difficulty: 6),
        Word(text: "government", difficulty: 6),
        Word(text: "knowledge", difficulty: 6),
        Word(text: "strength", difficulty: 6),
        Word(text: "thought", difficulty: 6),

        // DIFFICULTY 7
        Word(text: "embarrass", difficulty: 7),
        Word(text: "occurrence", difficulty: 7),
        Word(text: "accommodate", difficulty: 7),
        Word(text: "achievement", difficulty: 7),
        Word(text: "acknowledgment", difficulty: 7),
        Word(text: "acquaintance", difficulty: 7),
        Word(text: "approximate", difficulty: 7),
        Word(text: "archaeological", difficulty: 7),
        Word(text: "bibliography", difficulty: 7),
        Word(text: "camouflage", difficulty: 7),
        Word(text: "catastrophe", difficulty: 7),
        Word(text: "chrysanthemum", difficulty: 7),
        Word(text: "coincidence", difficulty: 7),
        Word(text: "commitment", difficulty: 7),
        Word(text: "committee", difficulty: 7),

        // DIFFICULTY 8
        Word(text: "conscientious", difficulty: 8),
        Word(text: "consequences", difficulty: 8),
        Word(text: "contemporary", difficulty: 8),
        Word(text: "controversy", difficulty: 8),
        Word(text: "correspondence", difficulty: 8),
        Word(text: "dissatisfied", difficulty: 8),
        Word(text: "entrepreneur", difficulty: 8),
        Word(text: "exaggerate", difficulty: 8),
        Word(text: "fascinate", difficulty: 8),
        Word(text: "fluorescent", difficulty: 8),
        Word(text: "guarantee", difficulty: 8),
        Word(text: "hemorrhage", difficulty: 8),
        Word(text: "humorous", difficulty: 8),
        Word(text: "immediately", difficulty: 8),
        Word(text: "independent", difficulty: 8),

        // DIFFICULTY 9
        Word(text: "inoculate", difficulty: 9),
        Word(text: "intelligence", difficulty: 9),
        Word(text: "interference", difficulty: 9),
        Word(text: "irresistible", difficulty: 9),
        Word(text: "kaleidoscope", difficulty: 9),
        Word(text: "liaison", difficulty: 9),
        Word(text: "maintenance", difficulty: 9),
        Word(text: "maneuver", difficulty: 9),
        Word(text: "mediterranean", difficulty: 9),
        Word(text: "millennium", difficulty: 9),
        Word(text: "miscellaneous", difficulty: 9),
        Word(text: "mischievous", difficulty: 9),
        Word(text: "occasionally", difficulty: 9),
        Word(text: "occurrence", difficulty: 9),
        Word(text: "onomatopoeia", difficulty: 9),

        // DIFFICULTY 10
        Word(text: "paradigm", difficulty: 10),
        Word(text: "parallel", difficulty: 10),
        Word(text: "perseverance", difficulty: 10),
        Word(text: "pharmaceutical", difficulty: 10),
        Word(text: "phenomenon", difficulty: 10),
        Word(text: "pneumonia", difficulty: 10),
        Word(text: "prejudice", difficulty: 10),
        Word(text: "privilege", difficulty: 10),
        Word(text: "pronunciation", difficulty: 10),
        Word(text: "psychiatry", difficulty: 10),
        Word(text: "questionnaire", difficulty: 10),
        Word(text: "reconnaissance", difficulty: 10),
        Word(text: "reminiscence", difficulty: 10),
        Word(text: "renaissance", difficulty: 10),
        Word(text: "rendezvous", difficulty: 10),

        // DIFFICULTY 11
        Word(text: "acquiesce", difficulty: 11),
        Word(text: "bourgeoisie", difficulty: 11),
        Word(text: "conscientious", difficulty: 11),
        Word(text: "entrepreneurship", difficulty: 11),
        Word(text: "idiosyncrasy", difficulty: 11),
        Word(text: "infinitesimal", difficulty: 11),
        Word(text: "magnanimous", difficulty: 11),
        Word(text: "metamorphosis", difficulty: 11),
        Word(text: "obsequious", difficulty: 11),
        Word(text: "ostentatious", difficulty: 11),
        Word(text: "perfunctory", difficulty: 11),
        Word(text: "perspicacious", difficulty: 11),
        Word(text: "pusillanimous", difficulty: 11),
        Word(text: "quintessential", difficulty: 11),
        Word(text: "serendipity", difficulty: 11),

        // DIFFICULTY 12 - Competition Level
        Word(text: "abstemious", difficulty: 12),
        Word(text: "antediluvian", difficulty: 12),
        Word(text: "appoggiatura", difficulty: 12),
        Word(text: "autochthonous", difficulty: 12),
        Word(text: "bougainvillea", difficulty: 12),
        Word(text: "chiaroscuro", difficulty: 12),
        Word(text: "eleemosynary", difficulty: 12),
        Word(text: "eudaemonic", difficulty: 12),
        Word(text: "floccinaucinihilipilification", difficulty: 12),
        Word(text: "guerrilla", difficulty: 12),
        Word(text: "laodicean", difficulty: 12),
        Word(text: "logorrhea", difficulty: 12),
        Word(text: "milquetoast", difficulty: 12),
        Word(text: "onomatopoeia", difficulty: 12),
        Word(text: "pococurante", difficulty: 12),
        Word(text: "prospicience", difficulty: 12),
        Word(text: "psittacosis", difficulty: 12),
        Word(text: "sacrilegious", difficulty: 12),
        Word(text: "stichomythia", difficulty: 12),
        Word(text: "succedaneum", difficulty: 12),
    ]
}

// MARK: - Sample Words Documentation
/*
 SAMPLE WORD LISTS BY GRADE AND LEVEL:

 Grade 1:
 - Level 1 (Difficulty 1): cat, dog, sun, run, big, red, hat, cup, bed, pen
 - Level 10 (Difficulty 1-2): play, jump, tree, book, look, ball, fish, wish
 - Level 25 (Difficulty 2-3): apple, happy, water, green, dream, sleep

 Grade 4:
 - Level 1 (Difficulty 4): friend, school, people, family, purple, yellow
 - Level 10 (Difficulty 4-5): beautiful, different, important, remember, tomorrow
 - Level 25 (Difficulty 5-6): environment, temperature, experiment, imagination

 Grade 7:
 - Level 1 (Difficulty 7): embarrass, occurrence, accommodate, achievement
 - Level 10 (Difficulty 7-8): conscientious, entrepreneur, exaggerate, guarantee
 - Level 25 (Difficulty 8-9): kaleidoscope, liaison, mediterranean, millennium
*/
