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
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(screens.indices, id: \.self) { index in
                if index == 1 {
                    Image(systemName: currentScreen == .profile ? "chevron.down" : "chevron.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(currentScreen == screens[index] ? .white : .gray.opacity(0.7))
                        .frame(width: 10, height: 25)
                        .animation(.easeInOut(duration: 0.3), value: currentScreen)
                } else {
                    Circle()
                        .frame(width: 10, height: 25)
                        .foregroundColor(currentScreen == screens[index] ? .white : .gray.opacity(0.7))
                        .animation(.spring(), value: currentScreen)
                }
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.3))
        )
    }
}
