//
//  TimerViewModel.swift
//  GTUp!
//
//  Created by Hendrik Nicolas Carlo on 10/05/25.
//

import Foundation
import SwiftUI

final class TimerViewModel: ObservableObject {
    private let manager: HealthKitManager
    private let breakRecord: Break
    
    @Published private(set) var prevStep: Int = 0
    @Published private(set) var currStep: Int = 0
    @Published private(set) var tempStep: Int = 0
    @Published private(set) var stepPatienceCounter: Int = 0
    
    // Initialize with dependencies
    init(manager: HealthKitManager, breakRecord: Break) {
        self.manager = manager
        self.breakRecord = breakRecord
    }
    
    func interuptTimer(time: Int) {
        if stepPatienceCounter < 1 {
            if time % 10 == 0 {
                print("fetching steps \(stepPatienceCounter)")
                manager.getTodayStep()
                currStep = manager.activity
                tempStep = currStep - prevStep
                
                if tempStep >= 50 {
                    stepPatienceCounter += 1
                } else {
                    stepPatienceCounter = 0
                }
                
                prevStep = currStep
            }
        } else {
            stepPatienceCounter = 0
            currStep = 0
            prevStep = 0
            tempStep = 0
        }
    }
}
