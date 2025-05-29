import SwiftUI

// MARK: - Main Profile View
struct ProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = UserDefaults.standard.string(forKey: "name") ?? "Carlo"
    @State private var age = UserDefaults.standard.string(forKey: "age") ?? "25"
    
    @State private var workingHoursStart = UserDefaults.standard.object(forKey: "workingHoursStart") as? Date ?? defaultDate(hour: 9)
    @State private var workingHoursEnd = UserDefaults.standard.object(forKey: "workingHoursEnd") as? Date ?? defaultDate(hour: 17)
    @State private var restHoursStart = UserDefaults.standard.object(forKey: "restHoursStart") as? Date ?? defaultDate(hour: 12)
    @State private var restHoursEnd = UserDefaults.standard.object(forKey: "restHoursEnd") as? Date ?? defaultDate(hour: 13)
    
    @State private var showingNotifications = false
    @State private var showingResearchStudies = false
    @State private var showingDevices = false
    @State private var showingApps = false
    
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isAgeFieldFocused: Bool
    
    // MARK: - Helper Methods
    
    private static func defaultDate(hour: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour)) ?? Date()
    }
    
    private func saveValues() {
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(age, forKey: "age")
        UserDefaults.standard.set(workingHoursStart, forKey: "workingHoursStart")
        UserDefaults.standard.set(workingHoursEnd, forKey: "workingHoursEnd")
        UserDefaults.standard.set(restHoursStart, forKey: "restHoursStart")
        UserDefaults.standard.set(restHoursEnd, forKey: "restHoursEnd")
    }
    
    private func dismissKeyboard() {
        isNameFieldFocused = false
        isAgeFieldFocused = false
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.primaryApp.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Main Content
                ZStack {
                    Color.primaryApp.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        mainContentList
                            .listStyle(InsetGroupedListStyle())
                            .scrollContentBackground(.hidden)
                            .foregroundColor(.fontApp)
                            .scrollDisabled(true)
                            .onScrollPhaseChange { _, newPhase in
                                if newPhase == .interacting {
                                    dismissKeyboard()
                                }
                            }
                        
                        // Sheets
                        .sheet(isPresented: $showingNotifications) {
                            notificationsSheet
                        }
                        .sheet(isPresented: $showingResearchStudies) {
                            researchStudiesSheet
                        }
                        .sheet(isPresented: $showingDevices) {
                            devicesSheet
                        }
                        .sheet(isPresented: $showingApps) {
                            AppsView(isPresented: $showingApps)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { dismissKeyboard() }
        )
    }
    
    // MARK: - Component Views
    
    private var headerView: some View {
        VStack {
            Spacer()
                .frame(height: 20)
            ZStack {
                // Center title
                
                Text("Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.fontApp)

                // Left-aligned back button
                HStack {
                    Button(action: {
                        dismiss() // Dismiss the current view to navigate back
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                            Text("Back")
                                .foregroundColor(.blue)
                                .font(.system(size: 17))
                        }
                        .padding(.leading)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 25)
        .background(.secondaryApp)
    }
    
    private var mainContentList: some View {
        List {
            // Personal Information Section
            Section(header: Text("Personal Information")) {
                // Name Row
                formTextField(label: "Name", text: $name)
                
                // Age Row
                formTextField(label: "Age", text: $age, isNumeric: true)

                // Working Hours Row
                formTimeRangePicker(
                    label: "Working Hours",
                    startTime: $workingHoursStart,
                    endTime: $workingHoursEnd
                )
                
                // Lunch Break Row
                formTimeRangePicker(
                    label: "Lunch Break",
                    startTime: $restHoursStart,
                    endTime: $restHoursEnd
                )
                
                // Notifications Row
                navigationRow(title: "Notifications") {
                    showingNotifications = true
                }
            }
            
            // Privacy & Resources Section
            Section(header: Text("Privacy & Resources")) {
                navigationRow(title: "Apps") {
                    showingApps = true
                }
                
                navigationRow(title: "Research Studies") {
                    showingResearchStudies = true
                }
                
                navigationRow(title: "Devices") {
                    showingDevices = true
                }
                
                Text("Your data is encrypted on your device and can only be shared with your permission.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 2)
                    .listRowBackground(Color.primaryApp)
            }
        }
    }
    
    // MARK: - Reusable Components
    
    private func formTextField(label: String, text: Binding<String>, isNumeric: Bool = false) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white)
            Spacer()
            TextField(label, text: text, onCommit: saveValues)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.trailing)
                .focused(isNumeric ? $isAgeFieldFocused : $isNameFieldFocused)
                .keyboardType(isNumeric ? .numberPad : .default)
        }
        .listRowBackground(Color.gray.opacity(0.2))
        .overlay(rowSeparator)
        .if(isNumeric) { view in
            view.toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { dismissKeyboard() }
                        .foregroundColor(.blue)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    private func formTimeRangePicker(label: String, startTime: Binding<Date>, endTime: Binding<Date>) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 5) {
                timePicker(selection: startTime)
                Text("-")
                    .foregroundColor(.white.opacity(0.7))
                timePicker(selection: endTime)
            }
        }
        .listRowBackground(Color.gray.opacity(0.2))
        .overlay(rowSeparator)
    }
    
    private func timePicker(selection: Binding<Date>) -> some View {
        DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
            .labelsHidden()
            .accentColor(.blue)
            .foregroundColor(.white)
            .environment(\.colorScheme, .dark)
            .frame(width: 70)
            .onChange(of: selection.wrappedValue) { _ in saveValues() }
    }
    
    private func navigationRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .listRowBackground(Color.gray.opacity(0.2))
        .overlay(rowSeparator)
    }
    
    private var rowSeparator: some View {
        Rectangle()
            .frame(height: 0.5)
            .foregroundColor(.white.opacity(0.3))
            .offset(y: 22)
    }
    
    // MARK: - Sheet Views
    
    private var notificationsSheet: some View {
        ModalView(title: "Notifications", isPresented: $showingNotifications) {
            VStack(alignment: .leading, spacing: 15) {
                Spacer().frame(height: 20)
                
                List {
                    NotificationSettingRow(title: "Activity Reminders", isOn: true)
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(rowSeparator)
                    
                    NotificationSettingRow(title: "Weekly Reports", isOn: true)
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(rowSeparator)
                    
                    NotificationSettingRow(title: "Goal Achievements", isOn: true)
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(rowSeparator)
                    
                    NotificationSettingRow(title: "Break Reminders", isOn: false)
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(rowSeparator)
                    
                    NotificationSettingRow(title: "App Updates", isOn: false)
                        .listRowBackground(Color.gray.opacity(0.2))
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                
                Text("You'll receive notifications according to these settings during your specified working hours.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                
                // Add spacer to fill remaining space
                Spacer()
                    .frame(height: 390) // Fixed height for vertical Spacer
            }
        }
    }
    
    private var researchStudiesSheet: some View {
        ModalView(title: "Research Studies", isPresented: $showingResearchStudies) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Active Research Studies")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    List {
                        researchStudyLink(
                            title: "Effects of Active Microbreak",
                            description: "How active microbreaks can positively impact the physical and mental well-being of office workers.",
                            content: "Risk factors associated with sedentary work and prolonged sitting time can be detrimental to office workers' health and productivity. Recent literature introduced the concept of active microbreaks and their benefits to sedentary workers. The purpose of this study was to better define active microbreaks and to determine the evidence behind utilizing active microbreaks at work, through a qualitative synthesis of the literature in a systematic review. A comprehensive systematic search was conducted using primarily ergonomics, medicine and allied health databases, in addition to grey literature (CINAHL, Google Scholar, PubMed, and ScienceDirect) and respective ergonomics journals. Six interventional controlled trials (232 total participants) met the inclusion criteria and qualified for the inclusion in this review. The quality of the reviewed articles was deemed to be moderate to high according to the utilized assessment scales. The results of this review may support the use of short active microbreaks (2–3 minutes of light intensity exercises every 30 minutes) due to the observed physical and mental health benefits without negative impact on productivity in the workplace.",
                            sourceLink: "https://www.tandfonline.com/doi/pdf/10.1080/23311916.2022.2026206"
                        )
                        
                        researchStudyLink(
                            title: "Workstation Setup Effects on Discomfort and Productivity",
                            description: "This study compares two workstation setups—ergonomically-fitted (Ergo-Fit) and self-adjusted—during a 60-minute sit-stand-walk computer task.",
                            content: "Compare musculoskeletal discomfort, productivity, postural risks, and perceived fatigue for a sit-stand-walk intervention between two workstation configurations – one, individually customized for office workers according to ergonomic guidelines (Ergo-Fit); another, self-adjusted by office workers according to their preference (Self-Adjusted).",
                            sourceLink: "https://www.sciencedirect.com/science/article/abs/pii/S0003687018307221"
                        )
                        
                        researchStudyLink(
                            title: "Computer Terminal Work and The Benefit of Microbreaks",
                            description: "The efect of `microbreak protocols on muscle activation behavior",
                            content: "Microbreaks are scheduled rest breaks taken to prevent the onset or progression of cumulative trauma disorders in the computerized workstation environment. The authors examined the benefit of microbreaks by investigating myoelectric signal (MES) behavior, perceived discomfort, and worker productivity while individuals performed their usual keying work. Participants were randomly assigned to one of three experimental groups. Each participant provided data from working sessions where they took no breaks, and from working sessions where they took breaks according to their group assignment: microbreaks at their own discretion (control), microbreaks at 20 min intervals, and microbreaks at 40 min intervals. Four main muscle areas were studied: the cervical extensors, the lumbar erector spinae, the upper trapezius/supraspinatus, and the wrist and finger extensors. The authors have previously shown that when computer workers remained seated at their workstation, the muscles performing sustained postural contractions displayed a cyclic trend in the mean frequency (MNF) of the MES (McLean et al., J. Electrophysiol. Kinesiol. 10 (1) (2000) 33). The data provided evidence (p < 0.05) that all microbreak protocols were associated with a higher frequency of MNF cycling at the wrist extensors, at the neck when microbreaks were taken by the control and 40 min protocol groups, and at the back when breaks were taken by the 20 and 40 min protocol groups. No significant change in the frequency of MNF cycling was noted at the shoulder. It was determined (p < 0.05) that microbreaks had a positive effect on reducing discomfort in all areas studied during computer terminal work, particularly when breaks were taken at 20 min intervals. Finally, microbreaks showed no evidence of a detrimental effect on worker productivity. The underlying cause of MNF cycling, and its relationship to the development of discomfort or cumulative trauma disorders remains to be determined.",
                            sourceLink: "https://www.researchgate.net/publication/11945902_Computer_terminal_work_and_the_benefit_of_microbreaks"
                        )
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    
                    Spacer()
                }
                .background(Color.black)
                .navigationBarHidden(true)
            }
        }
    }
    
    private func researchStudyLink(title: String, description: String, content: String, sourceLink: String) -> some View {
        NavigationLink {
            DetailView(
                title: title,
                content: content,
                sourceLink: sourceLink
            )
        } label: {
            ResearchStudyRow(
                title: title,
                description: description
            )
        }
        .listRowBackground(Color.gray.opacity(0.2))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.white.opacity(0.3))
                .padding(.horizontal, 5)
                .offset(y: 10),
            alignment: .bottom
        )
    }
    
    private var devicesSheet: some View {
        ModalView(title: "Devices", isPresented: $showingDevices) {
            VStack(alignment: .leading, spacing: 15) {
                Spacer().frame(height: 20)
                
                List {
                    deviceRow(
                        deviceName: "iPhone 15",
                        lastSynced: "Today, 14:30",
                        status: "Connected",
                        statusColor: .green
                    )
                    
                    deviceRow(
                        deviceName: "Apple Watch Series 10",
                        lastSynced: "Today, 14:25",
                        status: "Connected",
                        statusColor: .green
                    )
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                
                Text("These devices are currently linked to your account.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                
                Spacer()
                    .frame(height: 510) // Fixed height for vertical Spacer
            }
        }
    }
    
    private func deviceRow(deviceName: String, lastSynced: String, status: String, statusColor: Color) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(deviceName)
                    .foregroundColor(.white)
                Text("Last synced: \(lastSynced)")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Text(status)
                .foregroundColor(statusColor)
        }
        .listRowBackground(Color.gray.opacity(0.2))
        .listRowSeparator(.visible)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.white.opacity(0.3))
                .padding(.horizontal, 5)
                .offset(y: 10),
            alignment: .bottom
        )
    }
}

// MARK: - View Extensions
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Reusable Modal View
struct ModalView<Content: View>: View {
    let title: String
    @Binding var isPresented: Bool
    let content: Content
    
    init(title: String, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    Color(UIColor.darkGray).opacity(0.6)
                        .frame(height: 60)
                    
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack {
                        Spacer()
                        Button("Done") {
                            isPresented = false
                        }
                        .foregroundColor(.blue)
                        .padding(.trailing)
                    }
                }
                
                content
            }
        }
    }
}

// MARK: - Supporting Components

// Notification Setting Toggle Row
struct NotificationSettingRow: View {
    let title: String
    @State var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
    }
}

// Research Study Row for Lists
struct ResearchStudyRow: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            
            Image(systemName: "chevron.right")
                .foregroundColor(.blue)
        }
        .padding(.vertical, 5)
    }
}

// Detail View for Research Studies
struct DetailView: View {
    let title: String
    let content: String
    let sourceLink: String
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("Content")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(content)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Source")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    Link("Read more at the source", destination: URL(string: sourceLink)!)
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
    }
}

// Apps View with Swipe-to-Delete
struct AppsView: View {
    @Binding var isPresented: Bool
    
    @State private var apps: [(name: String, icon: String, access: String)] = [
        (name: "Health", icon: "heart.fill", access: "Heart Rate, Steps, Stand Hours"),
        (name: "Fitness", icon: "figure.walk", access: "Workouts, Activity Rings"),
        (name: "Calendar", icon: "calendar", access: "Events, Reminders")
    ]
    
    @State private var showDeleteAlert = false
    @State private var appToDelete: (name: String, icon: String, access: String)? = nil
    
    var body: some View {
        ModalView(title: "Apps", isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Manage your connected applications here.")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                    .padding(.top)
                
                List {
                    ForEach(apps, id: \.name) { app in
                        appRow(app: app)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                
                Text("You can view, add, or remove apps that have access to your data.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                
                Spacer()
                    .frame(height: 400) // Fixed height for vertical Spacer

            }
            .background(Color.black)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Remove App"),
                    message: Text("Are you sure you want to remove \(appToDelete?.name ?? "this app") from your connected apps?"),
                    primaryButton: .destructive(Text("Remove")) {
                        if let app = appToDelete {
                            apps.removeAll { $0.name == app.name }
                        }
                        appToDelete = nil
                    },
                    secondaryButton: .cancel() {
                        appToDelete = nil
                    }
                )
            }
        }
    }
    
    private func appRow(app: (name: String, icon: String, access: String)) -> some View {
        HStack {
            Image(systemName: app.icon)
                .foregroundColor(.red)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading) {
                Text(app.name)
                    .foregroundColor(.white)
                Text("Access: \(app.access)")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .listRowBackground(Color.gray.opacity(0.2))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.white.opacity(0.3))
                .offset(y: 30)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                appToDelete = app
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    ProfileView()
}
