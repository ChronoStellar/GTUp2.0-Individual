//
//  Stats.swift
//  CoreChal1
//
//  Created by Hendrik Nicolas Carlo on 07/04/25.
//

import Foundation
import SwiftData

@Model
class Break {
    var date : String = ""
    private var breakCounter : Int = 0 // how many times user took breaks
    private var breakTotal: Int = 0 // in minutes
    private var restDuration: Int = 60 // total mandatory rest / lunch break in minutes
    private var workDuration: Int = 0 // total workhour in minutes

    init(date: Date = Date()) {
        let temp = Calendar.current.startOfDay(for: date)
        self.date = temp.formattedAsQueryDate
        self.breakCounter = 0
        self.breakTotal = 0
    }
    
    //init
    func recordBreak() {
        breakCounter += 1
        let breakPeriods = breakTime()
        self.breakTotal += breakPeriods
    }
    //set
    func updateWorkDuration(_ duration: Int) {
        self.workDuration += duration
    }
    
    func updateRestDuration(){
        self.restDuration = UserDefaults.standard.integer(forKey: "breakMinutes")
        print("BreakUpdated: \(restDuration)")
    }
    
    //gets
    func getBreakCounter() -> Int {
        return breakCounter
    }
    func getDate() -> String {
        return date
    }
    func getBreakTotal() -> Int {
        return breakTotal
    }
    func getRestDuration() -> Int {
        return restDuration
    }
    func getWorkDuration() -> Double {
        return (Double(workDuration) / (60 * 60))
    }
    
    //genral functions
    func breakTime() -> Int{
        return UserDefaults.standard.integer(forKey: "breakMinutes") > 0 ? UserDefaults.standard.integer(forKey: "breakMinutes") : 1
    }
    
    func getTimeComponents(from date: Date) -> (hours: Int, minutes: Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        return (hours, minutes)
    }
}
