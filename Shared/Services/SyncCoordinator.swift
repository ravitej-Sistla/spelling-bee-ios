//
//  SyncCoordinator.swift
//  Shared
//
//  Orchestrates local cache operations.
//  Sync between devices is handled by PhoneSyncHelper (iOS) and WatchSyncHelper (watchOS).
//

import Foundation
import Combine

@MainActor
class SyncCoordinator: ObservableObject {
    static let shared = SyncCoordinator()

    @Published private(set) var syncStatus: SyncStatus = .idle
    @Published private(set) var lastSyncDate: Date?

    private let localCache = LocalCacheService.shared

    private init() {
        lastSyncDate = localCache.lastSyncDate
    }

    // MARK: - Profile Access

    func loadProfile() -> UserProfile? {
        return localCache.loadProfile()
    }

    func saveProfile(_ profile: UserProfile) {
        localCache.saveProfile(profile)
    }

    // MARK: - Reset

    func deleteAllData() {
        localCache.clearAll()
    }
}
