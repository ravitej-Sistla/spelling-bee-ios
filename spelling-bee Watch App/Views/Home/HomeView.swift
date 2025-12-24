//
//  HomeView.swift
//  spelling-bee Watch App
//
//  Main home screen showing levels and progress.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false

    var profile: UserProfile? {
        appState.profile
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Header
                    HeaderView(name: profile?.name ?? "Speller")

                    // Progress Summary
                    if let profile = profile {
                        ProgressSummaryView(profile: profile)
                    }

                    // Level Grid
                    LevelGridView()
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Levels")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    let name: String

    var body: some View {
        HStack {
            Text("🐝")
                .font(.title2)
            Text("Hi, \(name)!")
                .font(.caption)
                .foregroundColor(.cyan)
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Progress Summary
struct ProgressSummaryView: View {
    let profile: UserProfile

    var completedCount: Int {
        profile.completedLevels.count
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Grade \(profile.grade)")
                    .font(.caption2)
                    .foregroundColor(.cyan)
                Text("\(completedCount)/50")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Spacer()

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .white],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(completedCount) / 50)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 4)
    }
}

// MARK: - Level Grid
struct LevelGridView: View {
    @EnvironmentObject var appState: AppState

    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(1...50, id: \.self) { level in
                LevelButton(level: level)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Level Button
struct LevelButton: View {
    @EnvironmentObject var appState: AppState
    let level: Int

    var isUnlocked: Bool {
        appState.profile?.isLevelUnlocked(level) ?? false
    }

    var isCompleted: Bool {
        appState.profile?.isLevelCompleted(level) ?? false
    }

    var isCurrent: Bool {
        appState.profile?.currentLevel == level
    }

    var body: some View {
        Button {
            if isUnlocked {
                appState.navigateToGame(level: level)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(borderColor, lineWidth: isCurrent ? 2 : 0)
                    )

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                } else if isUnlocked {
                    Text("\(level)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .frame(height: 28)
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }

    var backgroundColor: Color {
        if isCompleted {
            return .cyan
        } else if isCurrent {
            return .cyan.opacity(0.7)
        } else if isUnlocked {
            return .white.opacity(0.2)
        } else {
            return .white.opacity(0.1)
        }
    }

    var borderColor: Color {
        isCurrent ? .white : .clear
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.9),
                    Color(red: 0.5, green: 0.3, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            HomeView()
                .environmentObject(AppState())
        }
    }
}
