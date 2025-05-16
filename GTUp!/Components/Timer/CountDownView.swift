//
//  TimerCountDownView.swift
//  GTUp!
//
//  Created by Hendrik Nicolas Carlo on 15/05/25.
//

import SwiftUI

struct TimerCountDownView: View {
    var endDate = Date()
    
    var body: some View {
        Text(endDate, style: .timer)
            .font(.system(size: 25, weight: .medium))
            .foregroundColor(.fontApp)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
        
    }
}

#Preview {
    TimerCountDownView(endDate: .now)
}
