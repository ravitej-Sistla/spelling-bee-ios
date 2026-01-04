//
//  PhoneSyncHelper.swift
//  spelling-bee iOS App
//
//  Handles phone-to-watch sync via WatchConnectivity.
//

import Foundation
import WatchConnectivity
import Combine

@MainActor
class PhoneSyncHelper: NSObject, ObservableObject {
    static let shared = PhoneSyncHelper()

    @Published private(set) var isWatchReachable = false
    @Published private(set) var syncStatus: SyncStatus = .idle

    private let session: WCSession
    private let localCache = LocalCacheService.shared

    private override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Sync Methods

    /// Called when app becomes active - request profile from Watch if needed
    func syncOnAppear() {
        guard session.isReachable else {
            syncStatus = .idle
            return
        }

        syncStatus = .syncing

        // Request profile from Watch to merge
        session.sendMessage(
            ["action": "requestProfile"],
            replyHandler: { [weak self] reply in
                Task { @MainActor in
                    self?.handleProfileReply(reply)
                }
            },
            errorHandler: { [weak self] error in
                Task { @MainActor in
                    print("Watch sync error: \(error)")
                    self?.syncStatus = .error(error.localizedDescription)
                }
            }
        )
    }

    private func handleProfileReply(_ reply: [String: Any]) {
        if let profileData = reply["profile"] as? Data,
           let remoteProfile = try? JSONDecoder().decode(SyncableProfile.self, from: profileData) {

            // Merge with local
            if let local = localCache.loadSyncableProfile() {
                let merged = SyncableProfile.merge(local: local, remote: remoteProfile)
                localCache.saveSyncableProfile(merged)

                // If local was newer, send it to Watch
                if merged.lastModified == local.lastModified {
                    sendProfileToWatch(local)
                }
            } else {
                // No local profile, use remote
                localCache.saveSyncableProfile(remoteProfile)
            }

            syncStatus = .success
        } else if reply["noProfile"] as? Bool == true {
            // Watch has no profile, send ours if we have one
            if let local = localCache.loadSyncableProfile() {
                sendProfileToWatch(local)
            }
            syncStatus = .success
        } else {
            syncStatus = .idle
        }
    }

    /// Send profile to Watch
    func sendProfileToWatch(_ profile: SyncableProfile) {
        guard session.isReachable else { return }

        guard let data = try? JSONEncoder().encode(profile) else { return }

        session.sendMessage(
            ["action": "profileUpdated", "profile": data],
            replyHandler: nil,
            errorHandler: { error in
                print("Failed to send profile to Watch: \(error)")
            }
        )
    }

    /// Called after local profile changes - push to Watch
    func pushLocalChanges() {
        if let local = localCache.loadSyncableProfile(), session.isReachable {
            sendProfileToWatch(local)
        }
    }
}

// MARK: - WCSessionDelegate

extension PhoneSyncHelper: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            isWatchReachable = session.isReachable
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        // Required for iOS
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Required for iOS - reactivate session
        session.activate()
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            isWatchReachable = session.isReachable
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            handleReceivedMessage(message)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            handleReceivedMessage(message, replyHandler: replyHandler)
        }
    }

    @MainActor
    private func handleReceivedMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        if let action = message["action"] as? String {
            switch action {
            case "requestSync":
                // Watch is requesting our profile
                if let local = localCache.loadSyncableProfile(),
                   let data = try? JSONEncoder().encode(local) {
                    replyHandler?(["profile": data])
                } else {
                    replyHandler?(["noProfile": true])
                }

            case "updateProfile":
                // Watch pushed an updated profile
                if let profileData = message["profile"] as? Data,
                   let remoteProfile = try? JSONDecoder().decode(SyncableProfile.self, from: profileData) {

                    if let local = localCache.loadSyncableProfile() {
                        let merged = SyncableProfile.merge(local: local, remote: remoteProfile)
                        localCache.saveSyncableProfile(merged)
                    } else {
                        localCache.saveSyncableProfile(remoteProfile)
                    }
                }

            case "requestProfile":
                // Watch is asking for our profile
                if let local = localCache.loadSyncableProfile(),
                   let data = try? JSONEncoder().encode(local) {
                    replyHandler?(["profile": data])
                } else {
                    replyHandler?(["noProfile": true])
                }

            default:
                break
            }
        }
    }
}
