import SwiftUI
import UIKit

// MARK: - UIViewRepresentable for UIPickerView
struct TimerPicker: UIViewRepresentable {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: TimerPicker
        
        init(parent: TimerPicker) {
            self.parent = parent
        }
        
        // MARK: - UIPickerViewDataSource
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0: return 24 // Hours (0-23)
            case 1, 2: return 60 // Minutes and Seconds (0-59)
            default: return 0
            }
        }
        
        // MARK: - UIPickerViewDelegate
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return String(format: "%02d", row)
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch component {
            case 0:
                parent.hours = row
            case 1:
                parent.minutes = row
            case 2:
                parent.seconds = row
            default:
                break
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        
        // Set initial selection
        picker.selectRow(hours, inComponent: 0, animated: false)
        picker.selectRow(minutes, inComponent: 1, animated: false)
        picker.selectRow(seconds, inComponent: 2, animated: false)
        
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        // Update picker selection if bindings change externally
        uiView.selectRow(hours, inComponent: 0, animated: true)
        uiView.selectRow(minutes, inComponent: 1, animated: true)
        uiView.selectRow(seconds, inComponent: 2, animated: true)
    }
}

// MARK: - SwiftUI View
struct ContentView_2: View {
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Timer Picker")
                .font(.title)
            
            TimerPicker(hours: $hours, minutes: $minutes, seconds: $seconds)
                .frame(height: 150)
            
            Text(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
                .font(.title2)
                .padding()
            
            Button("Reset") {
                hours = 0
                minutes = 0
                seconds = 0
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_2()
    }
}
