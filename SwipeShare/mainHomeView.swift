import SwiftUI

struct MainHomeView: View {
    @State private var isSwipeGiver = false // Toggle this to switch between views
    @State private var userRole: String? = nil // FOR TESTING PURPOSES ONLY

    var body: some View {
        NavigationView {
            VStack {
                if let userRole = userRole {
                    if userRole == "giver" {
                        GiverHomeView()
                    } else {
                        ReceiverHomeView1()
                    }
                } else {
                    ReceiverHomeView1()
                }
                
                // Button to toggle between Giver and Receiver for testing
                Button(action: {
                    isSwipeGiver.toggle()
                }) {
                    Text("Toggle User Type")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .onAppear {
                // fetch the user type from UserDefaults
                self.userRole = UserData.getUserRole()
            }
        }
    }
}

struct MainHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView()
    }
}

