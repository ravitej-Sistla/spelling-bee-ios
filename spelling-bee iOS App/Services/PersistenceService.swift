//
//  PersistenceService.swift
//  spelling-bee iOS App
//
//  Handles local data persistence using UserDefaults.
//

import Foundation

class PersistenceService {
    static let shared = PersistenceService()

    private let profileKey = "userProfile_iOS"

    func saveProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }

    func loadProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }

    func deleteProfile() {
        UserDefaults.standard.removeObject(forKey: profileKey)
    }
}
