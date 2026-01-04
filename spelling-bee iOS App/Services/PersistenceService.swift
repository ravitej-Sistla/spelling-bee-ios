//
//  PersistenceService.swift
//  spelling-bee iOS App
//
//  Handles local data persistence, delegating to shared LocalCacheService.
//

import Foundation

class PersistenceService {
    static let shared = PersistenceService()

    private let localCache = LocalCacheService.shared

    func saveProfile(_ profile: UserProfile) {
        localCache.saveProfile(profile)
    }

    func loadProfile() -> UserProfile? {
        return localCache.loadProfile()
    }

    func deleteProfile() {
        localCache.clearAll()
    }
}
