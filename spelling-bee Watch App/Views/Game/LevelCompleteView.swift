//
//  LevelCompleteView.swift
//  spelling-bee Watch App
//
//  Celebration screen shown when a level is completed.
//

import SwiftUI

struct LevelCompleteView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: GameViewModel

    let level: Int

    @State private var showConfetti = false
    @State private var starScale: CGFloat = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            // Confetti background
            ConfettiView(isActive: $showConfetti)

            VStack(spacing: 12) {
                Spacer()

                // Trophy/Star
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.cyan, .white.opacity(0.3)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 70, height: 70)
                        .scaleEffect(starScale)

                    Text("⭐")
                        .font(.system(size: 40))
                        .scaleEffect(starScale)
                }

                // Celebration text
                VStack(spacing: 4) {
                    Text("Level \(level)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Complete!")
                        .font(.headline)
                        .foregroundColor(.cyan)
                }
                .opacity(textOpacity)

                Spacer()

                // Continue button
                Button {
                    // Save progress and go home
                    appState.completeLevel(level)
                    appState.navigateToHome()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .padding(.horizontal)
                .opacity(textOpacity)
            }
            .padding()
        }
        .onAppear {
            animateCelebration()
        }
    }

    private func animateCelebration() {
        // Star bounce in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2)) {
            starScale = 1.0
        }

        // Text fade in
        withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
            textOpacity = 1.0
        }

        // Confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showConfetti = true
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onChange(of: isActive) { active in
                if active {
                    createParticles(in: geo.size)
                }
            }
        }
    }

    private func createParticles(in size: CGSize) {
        let colors: [Color] = [.cyan, .white, .blue, .mint, .pink, .purple]

        for i in 0..<20 {
            let particle = ConfettiParticle(
                id: i,
                color: colors.randomElement() ?? .cyan,
                size: CGFloat.random(in: 4...8),
                position: CGPoint(x: size.width / 2, y: size.height / 2),
                opacity: 1.0
            )
            particles.append(particle)
        }

        // Animate particles outward
        withAnimation(.easeOut(duration: 1.5)) {
            for i in particles.indices {
                particles[i].position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
                particles[i].opacity = 0
            }
        }

        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            particles.removeAll()
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
}

struct LevelCompleteView_Previews: PreviewProvider {
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

            LevelCompleteView(viewModel: GameViewModel(), level: 1)
                .environmentObject(AppState())
        }
    }
}
