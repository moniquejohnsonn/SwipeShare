import SwiftUI

struct ReceiverHomeView: View {
    @Binding var isSwipeGiverChecked: Bool
    
    var body: some View {
        VStack {
            Text("Receiver Home")
                .font(.largeTitle)
                .padding()
            
            Toggle("Check Swipe Giver", isOn: $isSwipeGiverChecked)
                .padding()
        }
    }
}

