//
//  DateTimerView.swift
//  GTUp!
//
//  Created by Hendrik Nicolas Carlo on 15/05/25.
//
import SwiftUI

struct DateTimerView: View {
    let date: Date
    
    var body: some View {
        Text(
            timerInterval: Date.now...date,
            countsDown: true
        )
        .monospacedDigit()
   }
}
