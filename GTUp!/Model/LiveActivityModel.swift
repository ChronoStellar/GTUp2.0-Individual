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
        var endDate: Date
        var countWork: Int
        var countBreak: Int
        
        var image: String {
            switch cycle {
            case "Work":
                return "work-sit"
            case "Break":
                return "walking"
            default:
                return ""
            }
        }
    }
    var Id: String
}
