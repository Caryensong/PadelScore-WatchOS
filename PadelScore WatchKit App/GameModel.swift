// GameModel.swift
// Observable game-state model for a single padel match.
//
// Swift vs JavaScript – key concepts explained:
//
// 1. Classes & ObservableObject
//    In JS you might use a plain object or a React state hook.
//    Here, `GameModel` is an ObservableObject (similar to a reactive
//    store in Vue/MobX). When a @Published property changes, SwiftUI
//    automatically re-renders any view that subscribes to this object.
//
// 2. @Published vs useState
//    `@Published var p1Points` is roughly equivalent to:
//      const [p1Points, setP1Points] = useState(0)
//    The compiler generates the setter and notification boilerplate
//    for you behind the scenes.
//
// 3. Closures vs Arrow Functions
//    JS:    const addPoint = (player) => { ... }
//    Swift: func addPoint(to player: Int) { ... }
//    Swift closures look like: { (player: Int) in ... }
//    They capture `self` similarly to arrow functions in a class,
//    but you must write `self.` explicitly inside escaping closures
//    to make the capture clear to the compiler and to ARC.
//
// 4. Access control
//    `private func` = module-private helper, no JS equivalent
//    (JS has `#privateMethod` only in newer class syntax).

import Foundation
import WatchKit

// MARK: - Score helpers

/// The displayable string for a raw point count (0–4).
/// 4 only occurs as an "Advantage" state after Deuce.
private func pointLabel(_ raw: Int) -> String {
    switch raw {
    case 0:  return "0"
    case 1:  return "15"
    case 2:  return "30"
    case 3:  return "40"
    case 4:  return "Ad"
    default: return "0"
    }
}

// MARK: - GameModel

final class GameModel: ObservableObject {

    // MARK: Published state

    /// Raw point counter for Player 1 within the current game.
    /// Values: 0 = love, 1 = 15, 2 = 30, 3 = 40, 4 = Advantage
    @Published var p1Points: Int = 0

    /// Raw point counter for Player 2 within the current game.
    @Published var p2Points: Int = 0

    /// Games won by Player 1 in the current set.
    @Published var p1Games: Int = 0

    /// Games won by Player 2 in the current set.
    @Published var p2Games: Int = 0

    /// Sets won by Player 1.
    @Published var p1Sets: Int = 0

    /// Sets won by Player 2.
    @Published var p2Sets: Int = 0

    /// When true, a single point at Deuce decides the game (no Advantage).
    @Published var isGoldenPoint: Bool = false

    // MARK: Computed display properties

    var p1ScoreDisplay: String { pointLabel(p1Points) }
    var p2ScoreDisplay: String { pointLabel(p2Points) }

    /// Human-readable status shown between the two score buttons.
    var statusText: String {
        if p1Points == 4 { return "Adv. P1" }
        if p2Points == 4 { return "Adv. P2" }
        if isDeuce       { return isGoldenPoint ? "🏆 Golden Point" : "Deuce" }
        return ""
    }

    private var isDeuce: Bool {
        p1Points == 3 && p2Points == 3
    }

    // MARK: Actions

    /// Award a point to `player` (1 or 2) and trigger haptic feedback.
    func addPoint(to player: Int) {
        WKInterfaceDevice.current().play(.click)

        if player == 1 {
            handlePoint(myPoints: &p1Points,
                        oppPoints: &p2Points,
                        myGames: &p1Games,
                        oppGames: &p2Games,
                        mySets: &p1Sets,
                        oppSets: &p2Sets)
        } else {
            handlePoint(myPoints: &p2Points,
                        oppPoints: &p1Points,
                        myGames: &p2Games,
                        oppGames: &p1Games,
                        mySets: &p2Sets,
                        oppSets: &p1Sets)
        }
    }

    /// Reset the entire match to the initial state.
    func reset() {
        p1Points = 0;  p2Points = 0
        p1Games  = 0;  p2Games  = 0
        p1Sets   = 0;  p2Sets   = 0
    }

    // MARK: Private helpers

    /// Generic point-award logic using inout references so the same
    /// code path serves both players without duplication.
    ///
    /// Swift's `inout` parameters are similar to passing a reference in JS:
    ///   function update(ref) { ref.value += 1 }
    /// Here we use `&` at the call site and `inout` in the signature.
    private func handlePoint(myPoints:  inout Int,
                             oppPoints: inout Int,
                             myGames:   inout Int,
                             oppGames:  inout Int,
                             mySets:    inout Int,
                             oppSets:   inout Int) {
        let oppHasAdvantage = oppPoints == 4
        let iHaveAdvantage  = myPoints  == 4

        if iHaveAdvantage {
            // I had Advantage → win the game
            winGame(myGames: &myGames, oppGames: &oppGames,
                    mySets: &mySets, oppSets: &oppSets,
                    myPoints: &myPoints, oppPoints: &oppPoints)
            return
        }

        if oppHasAdvantage {
            // Opponent had Advantage → cancel it, back to Deuce
            oppPoints = 3
            return
        }

        // Normal point increment
        myPoints += 1

        if myPoints == 4 {
            if oppPoints == 3 {
                // Reached 40 when opponent is also at 40 → Deuce/Advantage
                if isGoldenPoint {
                    // Golden Point: win immediately
                    winGame(myGames: &myGames, oppGames: &oppGames,
                            mySets: &mySets, oppSets: &oppSets,
                            myPoints: &myPoints, oppPoints: &oppPoints)
                }
                // else: myPoints stays at 4 → displayed as "Ad"
            } else {
                // Straight win (opponent had < 3 points)
                winGame(myGames: &myGames, oppGames: &oppGames,
                        mySets: &mySets, oppSets: &oppSets,
                        myPoints: &myPoints, oppPoints: &oppPoints)
            }
        }
    }

    /// Record a game win, check for set win, then reset point counters.
    private func winGame(myGames:   inout Int,
                         oppGames:  inout Int,
                         mySets:    inout Int,
                         oppSets:   inout Int,
                         myPoints:  inout Int,
                         oppPoints: inout Int) {
        myGames += 1

        // Simple set win rule: first to 6 games (with 2-game lead).
        // Tiebreak at 6-6 is not implemented to keep the model concise.
        if myGames >= 6 && (myGames - oppGames) >= 2 {
            mySets  += 1
            myGames  = 0
            oppGames = 0
        }

        // Reset points for the next game
        myPoints  = 0
        oppPoints = 0

        // Stronger haptic for game/set won
        WKInterfaceDevice.current().play(.success)
    }
}
