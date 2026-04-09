// ContentView.swift
// Main UI for the PadelScore WatchOS app.
//
// Design decisions:
//  • Background: pure black (Color.black)
//  • Player 1 accent: neon green  (.neonGreen)
//  • Player 2 accent: padel-felt green (.feltGreen)
//  • Typography: system bold, large sizes
//  • Corner radius: 16 pt for all cards/buttons
//  • Haptic feedback: triggered inside GameModel.addPoint()
//
// Swift vs JS note – @StateObject:
//   `@StateObject var game = GameModel()` is the Swift equivalent of
//     const [game, setGame] = useState(() => new GameModel())
//   in React. SwiftUI keeps the object alive across re-renders of the
//   same view instance, just like a React ref that also triggers updates.

import SwiftUI

// MARK: - Player Button Style

/// A reusable button style that renders a full-width card with a
/// coloured gradient border. Mirrors the concept of a styled-component
/// in React or a CSS class applied to a <button>.
struct PlayerButtonStyle: ButtonStyle {
    let accentColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(accentColor, lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Score Card

/// A standalone view component for one player's score area.
/// Extracted into its own struct to keep ContentView concise –
/// analogous to breaking a large React component into smaller ones.
struct ScoreCard: View {
    let label: String
    let pointScore: String
    let games: Int
    let sets: Int
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(accentColor.opacity(0.8))

                Text(pointScore)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(accentColor)
                    .minimumScaleFactor(0.6)

                HStack(spacing: 6) {
                    Label("\(games)", systemImage: "gamecontroller.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))

                    Label("\(sets)", systemImage: "flag.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(accentColor.opacity(0.7))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .buttonStyle(PlayerButtonStyle(accentColor: accentColor))
    }
}

// MARK: - ContentView

struct ContentView: View {

    // @StateObject keeps the GameModel alive for the lifetime of this view.
    // The `game` object is created once and survives re-renders.
    @StateObject private var game = GameModel()

    // @State for local UI state (reset confirmation sheet).
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 6) {

                // ── Status banner ──────────────────────────────────
                statusBanner

                // ── Player score cards ─────────────────────────────
                HStack(spacing: 6) {
                    ScoreCard(
                        label: "P 1",
                        pointScore: game.p1ScoreDisplay,
                        games: game.p1Games,
                        sets:  game.p1Sets,
                        accentColor: .neonGreen,
                        action: { game.addPoint(to: 1) }
                    )

                    ScoreCard(
                        label: "P 2",
                        pointScore: game.p2ScoreDisplay,
                        games: game.p2Games,
                        sets:  game.p2Sets,
                        accentColor: .feltGreen,
                        action: { game.addPoint(to: 2) }
                    )
                }
                .frame(maxHeight: .infinity)

                // ── Controls row ───────────────────────────────────
                controlsRow
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        // Reset confirmation sheet
        .sheet(isPresented: $showResetConfirm) {
            resetSheet
        }
    }

    // MARK: Sub-views

    /// Displays "Deuce", "Adv. P1", "Golden Point", etc.
    /// Hidden when the string is empty (normal play).
    @ViewBuilder
    private var statusBanner: some View {
        let text = game.statusText
        if !text.isEmpty {
            Text(text)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.neonGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(Color.deepGreen.opacity(0.8))
                )
                .transition(.opacity)
        }
    }

    /// Golden Point toggle + Reset button.
    private var controlsRow: some View {
        HStack(spacing: 8) {
            // Golden Point toggle
            Toggle(isOn: $game.isGoldenPoint) {
                Text("GP")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(game.isGoldenPoint ? .neonGreen : .white.opacity(0.5))
            }
            .toggleStyle(.button)
            .tint(.deepGreen)
            .frame(maxWidth: .infinity)

            // Reset
            Button {
                showResetConfirm = true
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
    }

    /// Confirmation sheet shown before wiping the match.
    private var resetSheet: some View {
        VStack(spacing: 12) {
            Text("Reset Match?")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                Button("Cancel") {
                    showResetConfirm = false
                }
                .foregroundColor(.white.opacity(0.7))

                Button("Reset") {
                    game.reset()
                    showResetConfirm = false
                }
                .foregroundColor(.neonGreen)
                .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color.black)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
