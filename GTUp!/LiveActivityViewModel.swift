//
//  LiveActivityViewModel.swift
//  GTUp!
//
//  Created by Hendrik Nicolas Carlo on 10/05/25.
//

import SwiftUI
import ActivityKit
import SwiftData

struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var cycle: String
        var timer: String
        var countWork: Int
        var countBreak: Int
    }
    // Fixed non-changing properties about your activity go here!
    var ID: String
}

class LiveActivityManager {
    
    // Start a new Live Activity
    static func startLiveActivity() {
        // Ensure Live Activities are available on the device
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not available on this device.")
            return
        }
        
        // Create dummy attributes and initial state
        let attributes = LiveActivityAttributes(ID: "DummyActivity")
        let initialState = LiveActivityAttributes.ContentState(
            cycle: "Work",
            timer: "25:00",
            countWork: 2,
            countBreak: 5
        )
        
        do {
            // Request to start the Live Activity
            let activity = try Activity<LiveActivityAttributes>.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil // Set to .token if using push notifications
            )
            print("Live Activity started with ID: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }
    
    // Update the Live Activity with new dummy data
    static func updateLiveActivity() {
        Task {
            // New dummy state
            let updatedState = LiveActivityAttributes.ContentState(
                cycle: "Break",
                timer: "05:00",
                countWork: 3,
                countBreak: 10
            )
            
            // Find all active Live Activities
            for activity in Activity<LiveActivityAttributes>.activities {
                // Update the content state
                await activity.update(using: updatedState)
                print("Live Activity updated with ID: \(activity.id)")
            }
        }
    }
    
    // End the Live Activity
    static func endLiveActivity() {
        Task {
            // Final dummy state (optional, shown when dismissed)
            let finalState = LiveActivityAttributes.ContentState(
                cycle: "Finished",
                timer: "00:00",
                countWork: 4,
                countBreak: 15
            )
            
            // End all active Live Activities
            for activity in Activity<LiveActivityAttributes>.activities {
                await activity.end(using: finalState, dismissalPolicy: .default)
                print("Live Activity ended with ID: \(activity.id)")
            }
        }
    }
}
