//
//  spelling_bee_iOS_App.swift
//  spelling-bee iOS App
//
//  Main entry point for iOS spelling bee app.
//

import SwiftUI

@main
struct spelling_bee_iOS_App: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
