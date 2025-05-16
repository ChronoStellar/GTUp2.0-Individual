//
//  GTUp_App.swift
//  GTUp!
//
//  Created by Hendrik Nicolas Carlo on 05/05/25.
//

import SwiftUI

@main
struct GTUp_App: App {
    @StateObject var manager = HealthKitManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
                .modelContainer(for: Break.self)
//            TimerView(isTimerRunning: .constant(false))
        }
    }
}
