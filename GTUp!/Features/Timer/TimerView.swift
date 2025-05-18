import SwiftUI
import Combine
import UserNotifications

struct TimerView: View {
    //param
    let selectedBreak: Break?
    @Binding var isTimerRunning: Bool
    
    @StateObject private var viewModel: TimerViewModel
        
        // Initialize the view model with selectedBreak and other parameters
    init(selectedBreak: Break?, isTimerRunning: Binding<Bool>) {
        self.selectedBreak = selectedBreak
        self._isTimerRunning = isTimerRunning
        self._viewModel = StateObject(wrappedValue: TimerViewModel(endDate: .now, cycle: "Work", selectedBreak: selectedBreak))
    }
    
    @State private var selectedMode: String? = nil

    // Animation states (keeping only essentials for brevity)
    @State private var workScale: CGFloat = 1.0
    @State private var breakScale: CGFloat = 1.0
    @State private var lineScale: CGFloat = 1.0
    @State private var workOffset: CGSize = .zero
    @State private var breakOffset: CGSize = .zero
    @State private var lineOffsetXY: CGSize = .zero
    @State private var workImageOpacity: Double = 0
    @State private var breakImageOpacity: Double = 0
    @State private var workDurationOpacity: Double = 0
    @State private var breakDurationOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textScale: CGFloat = 0.5
    @State private var workPulse: CGFloat = 1.0
    @State private var breakPulse: CGFloat = 1.0

    // Long-press states
    @State private var isLongPressing: Bool = false
    @State private var longPressProgress: CGFloat = 0.0
    private let longPressDuration: Double = 1.0

    var body: some View {
            ZStack {
                Color.primaryApp
                    .ignoresSafeArea()

                // CurvedLine
                CurvedLine()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 300, height: 500)
                    .scaleEffect(lineScale)
                    .offset(lineOffsetXY)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: lineScale)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: lineOffsetXY)

                // Work object
                VStack(spacing: 25) {
                    Image("Work")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.white)
                        .opacity(workImageOpacity)
                        .animation(.easeInOut(duration: 0.5), value: workImageOpacity)

                    Text("Work")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .scaleEffect(textScale * workScale * workPulse)
                        .offset(workOffset)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: textScale)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: workPulse)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: workScale)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: workOffset)

                    TimerCountDownView(endDate: viewModel.endDate ?? Date().addingTimeInterval(60*5))
                        .opacity(workDurationOpacity)
                        .animation(.easeInOut(duration: 0.5), value: workDurationOpacity)
                }
                .position(
                    x: selectedMode == "Work" ? UIScreen.main.bounds.width / 2 : UIScreen.main.bounds.width / 3.5,
                    y: selectedMode == "Work" ? UIScreen.main.bounds.height / 2 : UIScreen.main.bounds.height / 5.6
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: selectedMode)
                .onTapGesture {
                    if !isTimerRunning {
                        withAnimation {
                            selectedMode = "Work"
                            workScale = 1.5
                            breakScale = 0.5
                            lineScale = 0.5
                            workOffset = .zero
                            breakOffset = CGSize(width: 100, height: 200)
                            lineOffsetXY = CGSize(width: 100, height: 200)
                            workImageOpacity = 1
                            breakImageOpacity = 0
                            workDurationOpacity = 1
                            breakDurationOpacity = 0
                            viewModel.startWorkTimer()
                            isTimerRunning = true
                        }
                    }
                }

                // Break object
                VStack(spacing: 25) {
                    Image("Break")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.white)
                        .opacity(breakImageOpacity)
                        .animation(.easeInOut(duration: 0.5), value: breakImageOpacity)

                    Text("Break")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .scaleEffect(textScale * breakScale * breakPulse)
                        .offset(breakOffset)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.4), value: textScale)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.3), value: breakPulse)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: breakScale)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: breakOffset)

                    TimerCountDownView(endDate: viewModel.endDate ?? Date().addingTimeInterval(60*5))
                        .opacity(breakDurationOpacity)
                        .animation(.easeInOut(duration: 0.5), value: breakDurationOpacity)
                }
                .position(
                    x: selectedMode == "Break" ? UIScreen.main.bounds.width / 2 : 3 * UIScreen.main.bounds.width / 4.4,
                    y: selectedMode == "Break" ? UIScreen.main.bounds.height / 2 : 2 * UIScreen.main.bounds.height / 3.6
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: selectedMode)
                .onTapGesture {
                    if !isTimerRunning {
                        withAnimation {
                            selectedMode = "Break"
                            breakScale = 1.5
                            workScale = 0.5
                            lineScale = 0.5
                            breakOffset = .zero
                            workOffset = CGSize(width: -100, height: -200)
                            lineOffsetXY = CGSize(width: -100, height: -200)
                            workImageOpacity = 0
                            breakImageOpacity = 1
                            workDurationOpacity = 0
                            breakDurationOpacity = 1
                            viewModel.startBreakTimer()
                            isTimerRunning = true
                        }
                    }
                }

                // Hold to Stop UI
                if isTimerRunning && (selectedMode == "Work" || selectedMode == "Break") {
                    VStack(spacing: 15) {
                        Text("Hold to Stop \(selectedMode ?? "")")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .zIndex(2)
                    .padding(20)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .position(
                        x: UIScreen.main.bounds.width / 2,
                        y: selectedMode == "Work" ? (UIScreen.main.bounds.height / 2 + 150) + 60 : (UIScreen.main.bounds.height / 2 + 150) + 60
                    )
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: selectedMode)
                    .gesture(
                        LongPressGesture(minimumDuration: longPressDuration)
                            .onChanged { _ in
                                print("Long press started")
                                startLongPress()
                            }
                            .onEnded { _ in
                                print("Long press ended")
                                stopLongPress()
                                resetToInitialState()
                            }
                    )
                }
            }
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("Error requesting notification permission: \(error)")
                    } else {
                        print("Notification permission granted: \(granted)")
                    }
                }

                withAnimation {
                    textOpacity = 1
                    textScale = 1
                }
            }
            .onChange(of: viewModel.isTimerRunning) { newValue in
                if !newValue && isTimerRunning {
                    resetToInitialState()
                }
            }
        }

        private func startLongPress() {
            isLongPressing = true
            longPressProgress = 0.0

            let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                longPressProgress += CGFloat(0.01 / longPressDuration)
                if longPressProgress >= 1.0 {
                    longPressProgress = 1.0
                    timer.invalidate()
                }
            }
            RunLoop.current.add(timer, forMode: .common)
        }

        private func stopLongPress() {
            isLongPressing = false
            longPressProgress = 0.0
        }

        private func resetToInitialState() {
            withAnimation {
                selectedMode = nil
                workScale = 1.0
                breakScale = 1 //Nesta = 1.0
                lineScale = 1.0
                workOffset = .zero
                breakOffset = .zero
                lineOffsetXY = .zero
                workImageOpacity = 0
                breakImageOpacity = 0
                workDurationOpacity = 0
                breakDurationOpacity = 0
                isTimerRunning = false
                viewModel.stopTimer()
            }
        }
}
