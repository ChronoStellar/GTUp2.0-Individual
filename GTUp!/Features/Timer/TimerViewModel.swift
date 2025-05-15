//
//  TimerViewModel.swift
//  GTUp!
//
//  Created by Hendrik Nicolas Carlo on 10/05/25.
//

import Foundation
import SwiftUI
import ActivityKit

final class TimerViewModel: ObservableObject {
    @Published var endDate: Date?
    @Published var cycle: String
    @Published var isTimerRunning: Bool = false
    private var activeActivity: Activity<LiveActivityAttributes>?
    private var timer: Timer?

    init(endDate: Date? = nil, cycle: String) {
        self.endDate = endDate
        self.cycle = cycle
    }

    // General Timer Functions
    func startTimer(duration: TimeInterval) {
        endDate = Date().addingTimeInterval(duration)
        isTimerRunning = true
        startLiveActivity()

        timer?.invalidate() // Prevent multiple timers
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self, let endDate else {
                timer.invalidate()
                return
            }
            if Date() >= endDate {
                stopTimer()
                timer.invalidate()
            }
        }
    }

    func stopTimer() {
        endDate = nil
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        stopLiveActivity()
    }

    func toggleTimer() {
        isTimerRunning.toggle()
    }

    // Cycle Timer
    func startWorkTimer() {
        cycle = "Work"
        let hours = UserDefaults.standard.integer(forKey: "timerHours")
        let minutes = UserDefaults.standard.integer(forKey: "timerMinutes")
        let seconds = UserDefaults.standard.integer(forKey: "timerSeconds")
        let totalTime = TimeInterval(getTotalTime(hours, minutes, seconds))
        startTimer(duration: totalTime)
    }

    func startBreakTimer() {
        cycle = "Break"
        let minutes = UserDefaults.standard.integer(forKey: "breakMinutes")
        let totalTime = TimeInterval(minutes * 60) // Convert minutes to seconds
        startTimer(duration: totalTime)
    }

    // Live Activity
    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not supported or enabled.")
            return
        }

        guard let endDate else {
            print("No endDate set for Live Activity.")
            return
        }

        let attributes = LiveActivityAttributes(Id: "Timer")
        let state = LiveActivityAttributes.ContentState(
            cycle: cycle,
            endDate: endDate,
            countWork: 10, // Replace with actual work count
            countBreak: 4, // Replace with actual break count
        )

        do {
            let activity = try Activity<LiveActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: endDate),
                pushType: nil
            )
            activeActivity = activity
            print("Live Activity started: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func stopLiveActivity() {
        Task {
            if let activity = activeActivity {
                await activity.end(nil, dismissalPolicy: .immediate)
                activeActivity = nil
                print("Live Activity stopped: \(activity.id)")
            }
        }
    }

    // General Functions
    private func getTotalTime(_ h: Int, _ m: Int, _ s: Int) -> Int {
        return h * 3600 + m * 60 + s
    }

    deinit {
        timer?.invalidate()
    }
}
