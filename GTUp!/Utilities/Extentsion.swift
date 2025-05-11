//
//  Extentsion.swift
//  GTUp!
//
//  Created by Hendrik Nicolas Carlo on 09/05/25.
//

import Foundation

extension Date {
    /// Returns a string formatted as "yyyy-MM-dd"
    var formattedAsQueryDate: String {
        return Date.queryFormatter.string(from: self)
    }
    
    /// Static DateFormatter for "yyyy-MM-dd" format
    private static let queryFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        formatter.locale = .current
        return formatter
    }()
    
    static func fromFormattedString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
    
    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Short weekday, e.g., "Sat"
        return formatter
    }()
    
    var formattedAsWeekday: String {
        return Date.weekdayFormatter.string(from: self)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd" // Two-digit day, e.g., "23"
        return formatter
    }()
    
    var formattedAsDay: String {
        return Date.dayFormatter.string(from: self)
    }
}
