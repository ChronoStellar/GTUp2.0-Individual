import Foundation
import SwiftUI
import ActivityKit

final class TimerViewModel: ObservableObject {
    @Published var endDate: Date?
    @Published var cycle: String
    @Published var isTimerRunning: Bool = false
    private var activeActivity: Activity<LiveActivityAttributes>?
    private var timer: Timer?
    private let selectedBreak: Break?
    private var pendingWorkSeconds: Int? // To store work duration for later update

    init(endDate: Date? = nil, cycle: String, selectedBreak: Break? = nil) {
        self.endDate = endDate
        self.cycle = cycle
        self.selectedBreak = selectedBreak
        self.pendingWorkSeconds = nil
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
                // Timer completed naturally
                if cycle == "Work", let workSeconds = pendingWorkSeconds {
                    selectedBreak?.updateWorkDuration(workSeconds)
                } else if cycle == "Break" {
                    selectedBreak?.recordBreak()
                }
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
        pendingWorkSeconds = nil // Clear pending work seconds
        stopLiveActivity()
    }

    // Cycle Timer
    func startWorkTimer() {
        cycle = "Work"
        let hours = UserDefaults.standard.integer(forKey: "timerHours")
        let minutes = UserDefaults.standard.integer(forKey: "timerMinutes")
        let seconds = UserDefaults.standard.integer(forKey: "timerSeconds")
        let totalSeconds = getTotalTime(hours, minutes, seconds)
        pendingWorkSeconds = totalSeconds // Store for later update
        let totalTime = TimeInterval(totalSeconds)
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
            countWork: Int(selectedBreak?.getWorkDuration() ?? 0),
            countBreak: Int(selectedBreak?.getBreakTotal() ?? 0)
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
            guard let activity = activeActivity else {
                print("No active Live Activity to stop.")
                return
            }
            do {
                await activity.end(nil, dismissalPolicy: .immediate)
                print("Live Activity stopped successfully: \(activity.id)")
                activeActivity = nil
                
                // Debug: List all active activities
                let activities = Activity<LiveActivityAttributes>.activities
                print("Remaining activities: \(activities.map { $0.id })")
            } catch {
                print("Failed to stop Live Activity: \(error)")
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
