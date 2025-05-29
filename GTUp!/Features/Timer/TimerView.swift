import SwiftUI
import Combine
import UserNotifications

struct TimerView: View {
    // Parameters
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
    @State private var showStartText: Bool = true
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
                
                VStack(alignment: .leading) {
                    if showStartText {
                        Text("Start")
                            .foregroundStyle(.fontApp)
                            .opacity(0.7)
                            .font(.system(size: 24, weight: .light))
                    }
                    
                    Text("Work")
                        .font(.system(size: 64, weight: .medium, design: .default))
                        .foregroundColor(.white)
                }
                .opacity(textOpacity)
                .scaleEffect(textScale * workScale)
                .offset(workOffset)
                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2), value: textScale)
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: workScale)
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: workOffset)

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
                        showStartText = false
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
                
                VStack(alignment: .leading) {
                    if showStartText {
                        Text("Take a")
                            .foregroundStyle(.fontApp)
                            .opacity(0.7)
                            .font(.system(size: 24, weight: .light))
                    }
                    
                    Text("Break")
                        .font(.system(size: 64, weight: .medium, design: .default))
                        .foregroundColor(.white)
                }
                .opacity(textOpacity)
                .scaleEffect(textScale * breakScale)
                .offset(breakOffset)
                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.4), value: textScale)
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: breakScale)
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: breakOffset)

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
                        showStartText = false
                        viewModel.startBreakTimer()
                        isTimerRunning = true
                    }
                }
            }

            // Hold to Stop UI
            if isTimerRunning && (selectedMode == "Work" || selectedMode == "Break") {
                VStack(spacing: 10) {
                    if isLongPressing {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: geometry.size.width, height: 10)
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: geometry.size.width * longPressProgress, height: 10)
                            }
                        }
                        .frame(width: 100, height: 10)
                    }
                    
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
                    y: (UIScreen.main.bounds.height / 2 + 150) + 60
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: selectedMode)
                .gesture(
                    LongPressGesture(minimumDuration: longPressDuration)
                        .onChanged { _ in
                            startLongPress()
                        }
                        .onEnded { _ in
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
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            updateLongPressProgress()
        }
    }

    private func startLongPress() {
        isLongPressing = true
        longPressProgress = 0.0

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }

    private func stopLongPress() {
        isLongPressing = false
        longPressProgress = 0.0

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }

    private func updateLongPressProgress() {
        guard isLongPressing else { return }
        
        longPressProgress += CGFloat(0.1 / longPressDuration)
        if longPressProgress >= 1.0 {
            longPressProgress = 1.0
        }
    }

    private func resetToInitialState() {
        withAnimation {
            selectedMode = nil
            workScale = 1.0
            breakScale = 1.0
            lineScale = 1.0
            workOffset = .zero
            breakOffset = .zero
            lineOffsetXY = .zero
            workImageOpacity = 0
            breakImageOpacity = 0
            workDurationOpacity = 0
            breakDurationOpacity = 0
            showStartText = true
            isTimerRunning = false
            viewModel.stopTimer()
        }
    }
}
