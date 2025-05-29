//
//  NavigationDotsView.swift
//  GTUp!
//
//  Created by Hendrik Nicolas Carlo on 09/05/25.
//

import SwiftUI

struct NavigationDotsView: View {
    @Binding var currentScreen: Screen
    
    private let screens: [Screen] = [.timer, .home, .data]
    private let icons: [Screen: String] = [
        .timer: "clock",
        .home: "house",
        .data: "chart.bar"
    ]
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(screens, id: \.self) { screen in
                Image(systemName: icons[screen] ?? "circle")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(currentScreen == screen ? .white : .primaryApp.opacity(0.8))
                    .frame(width: 15, height: 15)
                    .animation(.easeInOut(duration: 0.3), value: currentScreen)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.5))
            
        )
        
    }
}
