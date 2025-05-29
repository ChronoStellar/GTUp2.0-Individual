import SwiftUI
import SwiftData

enum Screen {
    case home
    case profile
    case data
    case timer
}

struct ContentView: View {
    @EnvironmentObject var manager: HealthKitManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var breaks: [Break] = []
    
    @State private var selectedDate: String
    
    @State private var currentScreen: Screen = .home
    @State private var tabIndex: Int = 1
    @State private var isProfileVisible: Bool = false
    @State private var profileDragOffset: CGFloat = UIScreen.main.bounds.height
    @GestureState private var dragState: CGFloat = 0
    @State private var isTimerRunning: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var profileOpacity: Double = 0.0
    
    // State untuk mengontrol visibilitas pemberitahuan swipe kiri/kanan
    @State private var showSwipeSideHint: Bool = true
    @State private var sideHintOpacity: Double = 0.0
    @State private var leftArrowOffset: CGFloat = 0.0
    @State private var rightArrowOffset: CGFloat = 0.0
    @State private var hasShownSwipeSideHint: Bool = false
    @State private var stopArrowAnimation: Bool = false
    
    private let tabScreens: [Screen] = [.timer, .home, .data]
    
    init() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayString = today.formattedAsQueryDate
        _selectedDate = State(initialValue: todayString)
        UserDefaults.standard.set(todayString, forKey: "todayDate")
        
        _hasShownSwipeSideHint = State(initialValue: false)
        _showSwipeSideHint = State(initialValue: true)
    }
    
    private var latestBreak: Break {
        let today = Calendar.current.startOfDay(for: Date()).formattedAsQueryDate
        let predicate = #Predicate<Break> { data in
            data.date == today
        }
        do {
            let descriptor = FetchDescriptor<Break>(predicate: predicate, sortBy: [SortDescriptor(\.date, order: .reverse)])
            let todayBreaks = try modelContext.fetch(descriptor)
            if let existingBreak = todayBreaks.last {
                print("Using existing Break for today: \(existingBreak.date)")
                return existingBreak
            } else {
                let newBreak = Break(date: Date())
                modelContext.insert(newBreak)
                try modelContext.save()
                print("Created new Break for today: \(newBreak.date)")
                return newBreak
            }
        } catch {
            print("Failed to fetch or save Break: \(error)")
            let newBreak = Break(date: Date())
            modelContext.insert(newBreak)
            return newBreak
        }
    }
    
    private var selectedBreak: Break? {
        breaks.first { $0.date == selectedDate }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ZStack {
                    TimerSetView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(x: offsetForIndex(0))
                        .opacity(opacityForIndex(0))
                        .allowsHitTesting(tabIndex == 0 && !isTimerRunning)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: tabIndex)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: dragOffset)
                    
                    TimerView(
                        selectedBreak: latestBreak,
                        isTimerRunning: $isTimerRunning
                    )
                    .environmentObject(manager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: offsetForIndex(1))
                    .opacity(opacityForIndex(1))
                    .allowsHitTesting(tabIndex == 1)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: tabIndex)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: dragOffset)
                    
                    DataView(selectedBreak: selectedBreak, selectedDate: $selectedDate)
                        .environmentObject(manager)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(x: offsetForIndex(2))
                        .opacity(opacityForIndex(2))
                        .allowsHitTesting(tabIndex == 2 && !isTimerRunning)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: tabIndex)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: dragOffset)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColor)
                .gesture(
                    isTimerRunning ? nil : DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let horizontalTranslation = value.translation.width
                            if horizontalTranslation > 50 && tabIndex > 0 {
                                tabIndex -= 1
                                currentScreen = tabScreens[tabIndex]
                                showSwipeSideHint = false
                            } else if horizontalTranslation < -50 && tabIndex < tabScreens.count - 1 {
                                tabIndex += 1
                                currentScreen = tabScreens[tabIndex]
                                showSwipeSideHint = false
                            }
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0)) {
                                dragOffset = 0
                            }
                        }
                )
                
                ProfileView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundColor)
                    .offset(y: isProfileVisible ? profileDragOffset + dragState : UIScreen.main.bounds.height + dragState)
                    .opacity(profileOpacity)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: profileDragOffset)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: profileOpacity)
                    .gesture(
                        isTimerRunning ? nil : DragGesture()
                            .updating($dragState) { value, state, _ in
                                if isProfileVisible {
                                    state = max(0, value.translation.height)
                                }
                            }
                            .onChanged { value in
                                if isProfileVisible {
                                    profileDragOffset = max(0, value.translation.height)
                                    let screenHeight = UIScreen.main.bounds.height
                                    profileOpacity = 1.0 - min(1.0, profileDragOffset / screenHeight)
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 100 {
                                    withAnimation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0)) {
                                        isProfileVisible = false
                                        currentScreen = tabScreens[tabIndex]
                                        profileDragOffset = UIScreen.main.bounds.height
                                        profileOpacity = 0.0
                                    }
                                } else {
                                    withAnimation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0)) {
                                        profileDragOffset = 0
                                        profileOpacity = 1.0
                                    }
                                }
                            }
                    )
                    .allowsHitTesting(!isTimerRunning)
                
                // Swipe hint
                if tabIndex == 1 && showSwipeSideHint && !isTimerRunning {
                    HStack {
                        VStack(spacing: 5) {
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(x: stopArrowAnimation ? 0 : leftArrowOffset)
                                    .animation(
                                        stopArrowAnimation ? nil : Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                        value: leftArrowOffset
                                    )
                                Text("Swipe left                                      to set timer")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .opacity(sideHintOpacity)
                        .padding(.leading, 5)
                        
                        Spacer()
                        
                        VStack(spacing: 5) {
                            HStack {
                                Spacer()
                                Text("Swipe right to see data")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.trailing)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(x: (stopArrowAnimation ? 0 : rightArrowOffset) - 5) // Shift left by 5 points
                                    .animation(
                                        stopArrowAnimation ? nil : Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                        value: rightArrowOffset
                                    )
                            }
                        }
                        .opacity(sideHintOpacity)
                        .padding(.trailing, 5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .onAppear {
                            startSideHintAnimation()
                        }
                    }
                }
                
                    
                
                // Profile icon with smooth animation
                VStack {
                    HStack {
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                            HStack(spacing: 5) {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 40, weight: .regular))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                        .offset(x: offsetForIndex(1))
                        .opacity(opacityForIndex(1))
                        .allowsHitTesting(tabIndex == 1 && !isTimerRunning)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: tabIndex)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: dragOffset)
                    }
                    Spacer()
                }
                
                // Navigation dots
                VStack {
                    Spacer()
                    NavigationDotsView(currentScreen: $currentScreen)
                        .padding(.bottom, 30)
                        .allowsHitTesting(!isTimerRunning)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            updateQuery()
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            updateQuery()
        }
    }
    
    
    private func startSideHintAnimation() {
        sideHintOpacity = 0.0
        leftArrowOffset = 0.0
        rightArrowOffset = 0.0
        stopArrowAnimation = false
        
        withAnimation(.easeInOut(duration: 0.5)) {
            sideHintOpacity = 0.8
        }
        
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            leftArrowOffset = -10
            rightArrowOffset = 10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.stopArrowAnimation = true
                self.leftArrowOffset = 0
                self.rightArrowOffset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    self.sideHintOpacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.showSwipeSideHint = false
                    self.hasShownSwipeSideHint = true
                }
            }
        }
    }
    
    private func offsetForIndex(_ index: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let position = CGFloat(index - tabIndex) * screenWidth
        return position + dragOffset
    }
    
    private func opacityForIndex(_ index: Int) -> Double {
        let screenWidth = UIScreen.main.bounds.width
        let position = abs(CGFloat(index - tabIndex) * screenWidth + dragOffset)
        let opacity = 1.0 - (position / screenWidth) * 0.3
        return max(0.7, min(1.0, opacity))
    }
    
    private var backgroundColor: Color {
        switch currentScreen {
        case .home: return Color.primaryApp
        case .profile: return Color.primaryApp
        case .data: return Color.primaryApp
        case .timer: return Color.primaryApp
        }
    }
    
    private func updateQuery() {
        let predicate = #Predicate<Break> { data in
            data.date == selectedDate
        }
        do {
            let descriptor = FetchDescriptor<Break>(predicate: predicate)
            breaks = try modelContext.fetch(descriptor)
            print("Fetched breaks for \(selectedDate): \(breaks.count)")
        } catch {
            print("Fetch failed: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager())
}
