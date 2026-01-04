//
//  SyncServiceProtocol.swift
//  Shared
//
//  Protocol abstraction for sync services.
//

import Foundation
import Combine

enum SyncError: Error {
    case notAuthenticated
    case networkUnavailable
    case recordNotFound
    case conflictDetected
    case encodingFailed
    case decodingFailed
    case unknown(Error)
}

enum SyncStatus: Equatable {
    case idle
    case syncing
    case success
    case error(String)
}

protocol SyncServiceProtocol {
    var syncStatus: AnyPublisher<SyncStatus, Never> { get }

    func fetchProfile() async throws -> SyncableProfile?
    func saveProfile(_ profile: SyncableProfile) async throws
    func deleteProfile() async throws
    func isAvailable() async -> Bool
}
