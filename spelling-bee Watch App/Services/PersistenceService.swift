//
//  PersistenceService.swift
//  spelling-bee Watch App
//
//  Handles local storage using UserDefaults for profile and progress.
//

import Foundation

class PersistenceService {
    static let shared = PersistenceService()

    private let userDefaults = UserDefaults.standard
    private let profileKey = "user_profile"

    private init() {}

    // MARK: - Profile Management

    /// Saves user profile to UserDefaults
    func saveProfile(_ profile: UserProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: profileKey)
        } catch {
            print("Failed to save profile: \(error)")
        }
    }

    /// Loads user profile from UserDefaults
    func loadProfile() -> UserProfile? {
        guard let data = userDefaults.data(forKey: profileKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            print("Failed to load profile: \(error)")
            return nil
        }
    }

    /// Checks if a profile exists
    var hasProfile: Bool {
        return loadProfile() != nil
    }

    /// Deletes the user profile (for testing/reset)
    func deleteProfile() {
        userDefaults.removeObject(forKey: profileKey)
    }

    // MARK: - Convenience Methods

    /// Updates profile with a new grade
    func updateGrade(_ grade: Int) {
        guard var profile = loadProfile() else { return }
        profile.grade = max(1, min(7, grade))
        saveProfile(profile)
    }

    /// Marks a level as completed
    func completeLevel(_ level: Int) {
        guard var profile = loadProfile() else { return }
        profile.completeLevel(level)
        saveProfile(profile)
    }
}
