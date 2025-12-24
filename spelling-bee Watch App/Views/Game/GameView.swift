//
//  GameView.swift
//  spelling-bee Watch App
//
//  Main gameplay screen with word presentation and spelling.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = GameViewModel()

    let level: Int

    var body: some View {
        VStack {
            switch viewModel.phase {
            case .presenting:
                WordPresentationView(viewModel: viewModel)
            case .spelling:
                SpellingInputView(viewModel: viewModel)
            case .feedback:
                FeedbackView(viewModel: viewModel)
            case .levelComplete:
                LevelCompleteView(viewModel: viewModel, level: level)
            }
        }
        .onAppear {
            if let grade = appState.profile?.grade {
                viewModel.startLevel(level: level, grade: grade)
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

// MARK: - Word Presentation View
struct WordPresentationView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Progress indicator
            ProgressBar(progress: viewModel.progress)
                .frame(height: 6)
                .padding(.horizontal)

            Text("\(viewModel.correctCount)/10")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            // Word indicator
            Text("🔊")
                .font(.system(size: 40))

            Text("Listen carefully!")
                .font(.caption)
                .foregroundColor(.cyan)

            Spacer()

            // Action buttons
            VStack(spacing: 8) {
                Button {
                    viewModel.repeatWord()
                } label: {
                    Label("Repeat", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.white.opacity(0.3))

                Button {
                    viewModel.startSpelling()
                } label: {
                    Label("Spell It!", systemImage: "pencil")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Spelling Input View
struct SpellingInputView: View {
    @ObservedObject var viewModel: GameViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Progress
            ProgressBar(progress: viewModel.progress)
                .frame(height: 6)
                .padding(.horizontal)

            Text("Type the spelling")
                .font(.caption)
                .foregroundColor(.cyan)

            // Text input with dictation support
            TextField("Spell here...", text: $viewModel.userSpelling)
                .textFieldStyle(.plain)
                .font(.system(.body, design: .monospaced))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(8)
                .background(Color.white.opacity(0.15))
                .foregroundColor(.white)
                .cornerRadius(8)
                .focused($isFocused)
                .padding(.horizontal)

            // Show current input
            if !viewModel.userSpelling.isEmpty {
                Text(viewModel.userSpelling.uppercased())
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.cyan)
            }

            Spacer()

            // Action buttons
            HStack(spacing: 8) {
                Button {
                    viewModel.repeatWord()
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.white.opacity(0.3))

                Button {
                    viewModel.submitSpelling()
                } label: {
                    Text("Done")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .disabled(viewModel.userSpelling.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))

                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
                    .animation(.easeOut(duration: 0.3), value: progress)
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
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

            GameView(level: 1)
                .environmentObject(AppState())
        }
    }
}
