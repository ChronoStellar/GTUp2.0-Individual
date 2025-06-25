//
//  GTUpWatchApp.swift
//  GTUpWatch Watch App
//
//  Created by Hendrik Nicolas Carlo on 25/06/25.
//

import SwiftUI

@main
struct GTUpWatch_Watch_AppApp: App {
    @StateObject private var timerViewModel = TimerViewModel() // Create an instance here
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerViewModel)
        }
    }
}
