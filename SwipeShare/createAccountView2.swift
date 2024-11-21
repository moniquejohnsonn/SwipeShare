import SwiftUI

struct LocationPermissionView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showCampusList = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // Progress Indicator View
                ProgressIndicatorView2()
                    .padding(.top, 64)
                
                // Title Text
                VStack(spacing: -19) { // Use negative spacing to reduce the gap
                    Text("Let's Find Your")
                        .font(.custom("BalooBhaina2-Bold", size: 48))
                        .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                    
                    Text("Campus")
                        .font(.custom("BalooBhaina2-Bold", size: 48))
                        .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                }
                .multilineTextAlignment(.center) // Centers the text
                .padding(.top, 112)
                
                
                Spacer().frame(height: 130) // Spacer to position the button below mid-screen
                
                // Share Location Button
                Button(action: {
                    // Handle share location action
                    locationManager.requestLocationAuthorization()
                }) {
                    Text("Share Location")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50) // Adjusted size for a bigger button
                        .background(Color(red: 0.03, green: 0.75, blue: 0.72))
                        .cornerRadius(100)
                }
                .padding(.top, 10)
                
                // Display location authorization status message
                if locationManager.locationAuthorized {
                    Text("Location access granted!")
                        .foregroundColor(.green)
                        .padding(.top, 20)
                } else {
                    Text("Please enable location access to find your campus.")
                        .foregroundColor(.red)
                        .padding(.top, 20)
                }
                
                
                Spacer() // Spacer to push content upwards
            }
            .frame(maxWidth: 480)
            .background(Color.white)
            .cornerRadius(32)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationDestination(isPresented: $showCampusList) {
            CampusPermissionView()
        }
        .onChange(of: locationManager.locationAuthorized) { newValue in
            if newValue {
                showCampusList = true
            }
                
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct LocationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        LocationPermissionView()
    }
}


// Progress Indicator View (Updated with Purple Circle
struct ProgressIndicatorView2: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 20) {
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.82, blue: 0.95))
                    .frame(width: 108, height: 1)
                
                Circle()
                    .strokeBorder(Color(red: 0.22, green: 0.11, blue: 0.47), lineWidth: 2)
                    .frame(width: 18, height: 18)
                
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.82, blue: 0.95))
                    .frame(width: 108, height: 1)
            }
            .frame(width: geometry.size.width, alignment: .center) // Center the HStack within the view
        }
        .frame(height: 20) // Set the height for the GeometryReader
    }
}
