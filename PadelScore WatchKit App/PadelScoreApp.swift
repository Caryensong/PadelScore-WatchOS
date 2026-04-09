// PadelScoreApp.swift
// Entry point for the PadelScore WatchOS app.
//
// Swift note for JS developers:
// The @main attribute marks the struct as the application entry point,
// similar to index.js / main.js in Node.js. There is no separate
// "main()" call needed; the framework calls into the App's `body`
// property automatically.

import SwiftUI

@main
struct PadelScoreApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
