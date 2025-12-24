//
//  OnboardingView.swift
//  spelling-bee Watch App
//
//  Main onboarding flow for new users.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var step: OnboardingStep = .welcome
    @State private var name = ""
    @State private var selectedGrade = 1

    enum OnboardingStep {
        case welcome
        case name
        case grade
    }

    var body: some View {
        VStack {
            switch step {
            case .welcome:
                WelcomeStepView(onContinue: { step = .name })
            case .name:
                NameInputStepView(name: $name, onContinue: { step = .grade })
            case .grade:
                GradeSelectionStepView(
                    selectedGrade: $selectedGrade,
                    onComplete: {
                        appState.createProfile(name: name, grade: selectedGrade)
                    }
                )
            }
        }
    }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("🐝")
                .font(.system(size: 50))

            Text("Spelling Bee")
                .font(.headline)
                .foregroundColor(.cyan)

            Text("Queen")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Learn to spell!")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))

            Button(action: onContinue) {
                Text("Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding()
    }
}

// MARK: - Name Input Step
struct NameInputStepView: View {
    @Binding var name: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("What's your name?")
                .font(.headline)
                .foregroundColor(.cyan)

            TextField("Name", text: $name)
                .textFieldStyle(.plain)
                .padding(8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
                .foregroundColor(.white)

            Button(action: onContinue) {
                Text("Next")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }
}

// MARK: - Grade Selection Step
struct GradeSelectionStepView: View {
    @Binding var selectedGrade: Int
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("Pick your grade")
                .font(.headline)
                .foregroundColor(.cyan)

            Picker("Grade", selection: $selectedGrade) {
                ForEach(1...7, id: \.self) { grade in
                    Text("Grade \(grade)")
                        .tag(grade)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 80)

            Button(action: onComplete) {
                Text("Let's Go!")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
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

            OnboardingView()
                .environmentObject(AppState())
        }
    }
}
