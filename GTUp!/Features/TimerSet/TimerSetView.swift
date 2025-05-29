//
//  TimerSetView.swift
//  CoreChal1
//
//  Created by Hendrik Nicolas Carlo on 24/03/25.
//

import SwiftUI

struct TimerSetView: View {
    @State private var hours: Int
    @State private var minutes: Int
    @State private var seconds: Int
    @State private var breakMinutes: Int
    @State private var tempHours: Int = 0
    @State private var tempMinutes: Int = 5
    @State private var tempSeconds: Int = 0
    @State private var tempBreakMinutes: Int = 5
    @State private var showTimePicker: Bool = false
    @State private var showBreakPicker: Bool = false
    
    // Alert type enum
    enum AlertType {
        case error
        case none
    }
    @State private var alertType: AlertType = .none
    @State private var showSuccessNotification: Bool = false // State for success notification
    
    @State private var selectedLabel: String = "None"
    @State private var selectedTimerEndOption: String
    @State private var isTimerEndMenuOpen: Bool = false // Track menu open state
    private let timerEndOptions = ["Vibrate", "Notification Only", "Ringing"]
    
    @State private var vibrateOn: Bool = true
    
    init() {
        // Retrieve values from UserDefaults
        let savedHours = UserDefaults.standard.integer(forKey: "timerHours")
        let savedMinutes = UserDefaults.standard.integer(forKey: "timerMinutes")
        let savedSeconds = UserDefaults.standard.integer(forKey: "timerSeconds")
        let savedBreakMinutes = UserDefaults.standard.integer(forKey: "breakMinutes")
        
        // If UserDefaults has no values (new app install), set default work time to 5 minutes
        if savedHours == 0 && savedMinutes == 0 && savedSeconds == 0 {
            _hours = State(initialValue: 0)
            _minutes = State(initialValue: 5) // Default 5 minutes
            _seconds = State(initialValue: 0)
            // Save defaults to UserDefaults
            UserDefaults.standard.set(0, forKey: "timerHours")
            UserDefaults.standard.set(5, forKey: "timerMinutes")
            UserDefaults.standard.set(0, forKey: "timerSeconds")
        } else {
            _hours = State(initialValue: savedHours)
            _minutes = State(initialValue: savedMinutes)
            _seconds = State(initialValue: savedSeconds)
        }
        
        // Set default break to 5 minutes if not set
        if savedBreakMinutes == 0 {
            _breakMinutes = State(initialValue: 5)
            UserDefaults.standard.set(5, forKey: "breakMinutes")
        } else {
            _breakMinutes = State(initialValue: savedBreakMinutes)
        }
        
        let savedLabel = UserDefaults.standard.string(forKey: "timerLabel") ?? "None"
        _selectedLabel = State(initialValue: savedLabel)
        
        let savedTimerEndOption = UserDefaults.standard.string(forKey: "timerEndOption") ?? "Vibrate"
        _selectedTimerEndOption = State(initialValue: savedTimerEndOption)
    }
    
    var body: some View {
        ZStack {
            Color.primaryApp
                .ignoresSafeArea()
            
            
            VStack {
                ZStack {
                    Color.secondaryApp
                    Text("Timer")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.fontApp)
                    Spacer()
                }
                .frame(height: 65)
                .background(.secondaryApp)
                
                // Work Duration Section
                VStack(spacing: 5) {
                    Text("Work Duration")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    
                    VStack(spacing: 5) {
                        Button(action: {
                            tempHours = hours
                            tempMinutes = minutes
                            tempSeconds = seconds
                            showTimePicker.toggle()
                        }) {
                            Text(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
                                .font(.system(size: 60, weight: .light, design: .default))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 60)
                    .background(Color.secondaryApp)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                // Break Duration Section
                VStack(spacing: 5) {
                    Text("Break Duration")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    VStack(spacing: 5) {
                        Button(action: {
                            tempBreakMinutes = breakMinutes
                            showBreakPicker.toggle()
                        }) {
                            Text(String(format: "%02d:%02d", breakMinutes, 0))
                                .font(.system(size: 38, weight: .light, design: .default))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 130)
                    .background(Color.secondaryApp)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Settings List
                VStack(spacing: 0) {
                    // Label Setting
                    HStack {
                        Text("Label")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Enter label", text: $selectedLabel)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.trailing)
                            .padding(.vertical, 1)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: 100)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 11)
                    .background(Color.secondaryApp)

                    // Separator
                    Rectangle()
                        .frame(height: 0.8)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.horizontal, 1)
                    
                    // When Timer Ends Setting
                    HStack {
                        Text("When Timer Ends")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Menu {
                            ForEach(timerEndOptions, id: \.self) { option in
                                Button(action: {
                                    selectedTimerEndOption = option
                                }) {
                                    Text(option)
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(selectedTimerEndOption)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                Image(systemName: isTimerEndMenuOpen ? "chevron.down" : "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: 150, alignment: .trailing)
                        }
                        .onTapGesture {
                            isTimerEndMenuOpen.toggle()
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isTimerEndMenuOpen = false
                            }
                        })
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 13)
                    .background(Color.secondaryApp)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
            
            // Success Notification
            if showSuccessNotification {
                VStack {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                        Text("Timer Set Successfully!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.green.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .transition(.opacity)
                }
                .position(x: UIScreen.main.bounds.width / 2, y: 100)
            }
            
            // Time Picker
            if showTimePicker {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showTimePicker = false // Allow tapping outside to dismiss
                    }

                VStack {
                    HStack {
                        Button("Cancel") {
                            showTimePicker = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Done") {
                            let totalSeconds = (tempHours * 3600) + (tempMinutes * 60) + tempSeconds
                            print("Total seconds: \(totalSeconds)")
                            
                            if totalSeconds < 1 {
                                print("Timer invalid, setting alertType to error")
                                alertType = .error
                            } else {
                                hours = tempHours
                                minutes = tempMinutes
                                seconds = tempSeconds
                                
                                print("Timer valid, saving to UserDefaults")
                                UserDefaults.standard.set(hours, forKey: "timerHours")
                                UserDefaults.standard.set(minutes, forKey: "timerMinutes")
                                UserDefaults.standard.set(seconds, forKey: "timerSeconds")
                                UserDefaults.standard.set(breakMinutes, forKey: "breakMinutes")
                                UserDefaults.standard.set(selectedLabel, forKey: "timerLabel")
                                UserDefaults.standard.set(selectedTimerEndOption, forKey: "timerEndOption")
                                
                                print("Timer set: \(hours)h \(minutes)m \(seconds)s, Break: \(breakMinutes)m, Label: \(selectedLabel), When Timer Ends: \(selectedTimerEndOption)")
                                
                                NotificationCenter.default.post(name: NSNotification.Name("TimerSetNotification"), object: nil)
                                
                                print("Showing success notification")
                                withAnimation {
                                    showSuccessNotification = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showSuccessNotification = false
                                    }
                                }
                                
                                showTimePicker = false
                            }
                        }
                        .foregroundColor(.blue.opacity(0.8))
                    }
                    .padding()
                    
                    HStack(spacing: 0) {
                        Picker("Hours", selection: $tempHours) {
                            ForEach(0..<24) { hour in
                                Text(String(format: "%02d", hour))
                                    .tag(hour)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        
//                        Text(":")
//                            .font(.system(size: 24, weight: .semibold))
//                            .foregroundColor(.white)
                        
                        Picker("Minutes", selection: $tempMinutes) {
                            ForEach(0..<60) { minute in
                                Text(String(format: "%02d", minute))
                                    .tag(minute)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        
//                        Text(":")
//                            .font(.system(size: 24, weight: .semibold))
//                            .foregroundColor(.white)
                        
                        Picker("Seconds", selection: $tempSeconds) {
                            ForEach(0..<60) { second in
                                Text(String(format: "%02d", second))
                                    .tag(second)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .environment(\.colorScheme, .dark)
                .alert(isPresented: Binding<Bool>(
                    get: { alertType != .none },
                    set: { _ in alertType = .none }
                )) {
                    print("Showing alert, type: \(alertType)")
                    switch alertType {
                    case .error:
                        return Alert(
                            title: Text("Invalid Timer"),
                            message: Text("Please set the timer to at least 1 second."),
                            dismissButton: .default(Text("OK"))
                        )
                    case .none:
                        return Alert(title: Text(""))
                    }
                }
            }
            
            // Break Picker
            if showBreakPicker {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showBreakPicker = false // Allow tapping outside to dismiss
                    }
                
                VStack {
                    HStack {
                        Button("Cancel") {
                            showBreakPicker = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Done") {
                            if tempBreakMinutes < 1 {
                                alertType = .error
                            } else {
                                breakMinutes = tempBreakMinutes
                                UserDefaults.standard.set(breakMinutes, forKey: "breakMinutes")
                                NotificationCenter.default.post(name: NSNotification.Name("BreakDurationSetNotification"), object: nil, userInfo: ["breakMinutes": breakMinutes])
                                showBreakPicker = false
                                withAnimation {
                                    showSuccessNotification = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showSuccessNotification = false
                                    }
                                }
                            }
                        }
                        .foregroundColor(.blue.opacity(0.8))
                    }
                    .padding()
                    
                    Picker("Break Duration", selection: $tempBreakMinutes) {
                        ForEach(1..<16) { minute in
                            Text("\(minute)m")
                                .tag(minute)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .environment(\.colorScheme, .dark)
                .alert(isPresented: Binding<Bool>(
                    get: { alertType != .none },
                    set: { _ in alertType = .none }
                )) {
                    switch alertType {
                    case .error:
                        return Alert(
                            title: Text("Invalid Break Duration"),
                            message: Text("Please set the break duration to at least 1 minute."),
                            dismissButton: .default(Text("OK"))
                        )
                    case .none:
                        return Alert(title: Text(""))
                    }
                }
            }
        }
    }
}

#Preview {
    TimerSetView()
}
