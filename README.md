# PadelScore – Apple Watch Padel Scorer

A native **watchOS** app built with **SwiftUI** that tracks scores for a Padel Tennis match directly on your Apple Watch.

---

## Features

| Feature | Details |
|---|---|
| **Two large player buttons** | Tap P1 or P2 to award a point |
| **Full tennis / padel scoring** | 0 → 15 → 30 → 40 → Ad → Game |
| **Deuce logic** | At 40-40: Advantage → Game (or back to Deuce) |
| **Golden Point toggle** | Switch from Deuce/Advantage to sudden-death at 40-40 |
| **Game & Set tracking** | First to 6 games (2-game lead) wins the set |
| **Haptic feedback** | `.click` on each point, `.success` on Game/Set win |
| **Reset** | Confirmation sheet before wiping all scores |
| **Design** | Pure-black background · Neon-green / Padel-felt-green palette · Rounded corners · Bold typography |

---

## Project Setup (Xcode)

1. Open **Xcode → File → New → Project**.
2. Choose the **watchOS → App** template.
3. Name the project `PadelScore`, set the bundle ID and team.
4. Delete the auto-generated placeholder Swift files.
5. Drag all four files from `PadelScore WatchKit App/` into the Xcode project navigator:
   - `PadelScoreApp.swift`
   - `GameModel.swift`
   - `Colors+Padel.swift`
   - `ContentView.swift`
6. Build & run on the Apple Watch Simulator (watchOS 9+ recommended).

---

## File Structure

```
PadelScore WatchKit App/
├── PadelScoreApp.swift   # @main entry point
├── GameModel.swift       # ObservableObject – all scoring logic
├── Colors+Padel.swift    # neonGreen / feltGreen / deepGreen palette
└── ContentView.swift     # SwiftUI views (ScoreCard, PlayerButtonStyle, …)
```

---

## Swift vs JavaScript – Quick Reference

> For developers coming from a JS / PHP background.

### State Management

| Concept | JavaScript (React) | Swift (SwiftUI) |
|---|---|---|
| Local component state | `const [x, setX] = useState(0)` | `@State var x = 0` |
| Shared reactive store | `useReducer` / MobX store | `class Model: ObservableObject` with `@Published var x` |
| Subscribe to store in a view | `useContext` / `observer()` | `@StateObject var model = Model()` |

### Closures vs Arrow Functions

```swift
// JavaScript arrow function
const add = (a, b) => a + b;

// Swift closure (same idea, different syntax)
let add: (Int, Int) -> Int = { a, b in a + b }

// Swift also supports trailing-closure syntax, which reads like a JS callback:
[1, 2, 3].forEach { number in
    print(number)          // "{ in }" replaces "=>"
}
```

Key difference: inside an **escaping** Swift closure (one that outlives the call site, e.g. a `DispatchQueue.async` block) you must write `self.` explicitly. This makes capture semantics visible to both the compiler and ARC (Automatic Reference Counting), unlike JavaScript where `this` is implicitly captured.

### `inout` Parameters vs Pass-by-Reference

```swift
// JS (simulated reference via object wrapper)
function increment(ref) { ref.value += 1; }

// Swift inout – caller uses &, callee declares inout
func increment(_ n: inout Int) { n += 1 }
var count = 0
increment(&count)   // count is now 1
```

### Access Control

```swift
private func helper() { }   // visible only within this file
// JS equivalent: #privateMethod() { }  (ES2022 class fields)
```
