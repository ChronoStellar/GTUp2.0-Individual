import SwiftUI
import ActivityKit

struct TestView: View {
    @State private var active: Activity<LiveActivityAttributes>? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Live Activity Test")
                .font(.headline)
            
            Button(action: {
                LiveActivityManager.startLiveActivity()
            }) {
                Text("Start Live Activity")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                LiveActivityManager.updateLiveActivity()
            }) {
                Text("Update Live Activity")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                LiveActivityManager.endLiveActivity()
            }) {
                Text("End Live Activity")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        // Optional: Start Live Activity automatically when the view appears
        .onAppear {
            // Uncomment the following to start the Live Activity automatically
            /*
            LiveActivityManager.startLiveActivity()
            
            // Update after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                LiveActivityManager.updateLiveActivity()
            }
            
            // End after 20 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                LiveActivityManager.endLiveActivity()
            }
            */
        }
    }
}

#Preview {
    TestView()
}
