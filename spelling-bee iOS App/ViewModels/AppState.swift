//
//  AppState.swift
//  spelling-bee iOS App
//
//  Global application state and navigation.
//

import Foundation
import SwiftUI

enum AppScreen: Equatable {
    case onboarding
    case home
    case game(level: Int)
    case settings
}

@MainActor
class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .onboarding
    @Published var profile: UserProfile?

    private let persistence = PersistenceService.shared

    init() {
        loadProfile()
    }

    func loadProfile() {
        if let savedProfile = persistence.loadProfile() {
            profile = savedProfile
            currentScreen = .home
        } else {
            currentScreen = .onboarding
        }
    }

    func createProfile(name: String, grade: Int) {
        let newProfile = UserProfile(name: name, grade: grade)
        profile = newProfile
        persistence.saveProfile(newProfile)
        currentScreen = .home
    }

    func updateGrade(_ grade: Int) {
        profile?.grade = grade
        if let profile = profile {
            persistence.saveProfile(profile)
        }
    }

    func completeLevel(_ level: Int) {
        profile?.completeLevel(level)
        if let profile = profile {
            persistence.saveProfile(profile)
        }
    }

    func navigateToHome() {
        currentScreen = .home
    }

    func navigateToGame(level: Int) {
        currentScreen = .game(level: level)
    }

    func navigateToSettings() {
        currentScreen = .settings
    }

    func resetApp() {
        persistence.deleteProfile()
        profile = nil
        currentScreen = .onboarding
    }
}
