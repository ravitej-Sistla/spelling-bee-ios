# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is a watchOS SwiftUI project. Build and test using Xcode or xcodebuild:

```bash
# Build the Watch App
xcodebuild -project spelling-bee.xcodeproj -scheme "spelling-bee Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 8 (45mm)' build

# Run unit tests
xcodebuild -project spelling-bee.xcodeproj -scheme "spelling-bee Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 8 (45mm)' test

# Run UI tests
xcodebuild -project spelling-bee.xcodeproj -scheme "spelling-bee Watch AppUITests" -destination 'platform=watchOS Simulator,name=Apple Watch Series 8 (45mm)' test
```

## Architecture

- **Platform**: watchOS 9.1+, Swift 5, SwiftUI
- **Pattern**: MVVM with ObservableObject
- **Entry Point**: `spelling_beeApp.swift` -> `ContentView.swift` (root navigation)

### App Flow

```
ContentView (root)
├── OnboardingView (first launch: name + grade selection)
├── HomeView (level grid with progress)
│   └── SettingsView (change grade, reset)
└── GameView (gameplay per level)
    ├── WordPresentationView (TTS speaks word)
    ├── SpellingInputView (speech recognition)
    ├── FeedbackView (correct/incorrect animations)
    └── LevelCompleteView (celebration)
```

### Key Services

- **SpeechService** (`Services/SpeechService.swift`): Text-to-speech (AVSpeechSynthesizer) and speech recognition (Speech framework). Handles phonetic letter mappings for spelling input.
- **WordBankService** (`Services/WordBankService.swift`): Word selection based on grade (1-7) and level (1-50). Difficulty = grade + (level-1)/10.
- **PersistenceService** (`Services/PersistenceService.swift`): UserDefaults storage for UserProfile.

### State Management

- **AppState** (`ViewModels/AppState.swift`): Global state via @EnvironmentObject. Manages screen navigation and profile.
- **GameViewModel** (`ViewModels/GameViewModel.swift`): Per-game session state. Tracks GamePhase: presenting → listening → feedback → levelComplete.

### Data Models

- **UserProfile**: name, grade, completedLevels (Set<Int>), currentLevel
- **Word**: text, difficulty (1-12 scale)
- **GameSession**: level, words, correctCount, progress tracking

## Targets

- `spelling-bee` - iOS container app (required for Watch app distribution)
- `spelling-bee Watch App` - The main watchOS application
- `spelling-bee Watch AppTests` - Unit tests
- `spelling-bee Watch AppUITests` - UI tests

## Required Capabilities

Add to Info.plist for speech recognition:
- `NSSpeechRecognitionUsageDescription`
- `NSMicrophoneUsageDescription`

## Adding New Files to Xcode

After creating new Swift files, add them to the project in Xcode:
1. Open `spelling-bee.xcodeproj`
2. Right-click "spelling-bee Watch App" folder
3. Select "Add Files to spelling-bee..."
4. Select the new files and ensure "spelling-bee Watch App" target is checked
