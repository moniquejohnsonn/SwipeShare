import SwiftUI

struct LocationPermissionView3: View {
    @State private var selectedCampus: String = "Columbia University"
    let campuses = ["Columbia University", "more coming soon!"]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // Progress Indicator View
                ProgressIndicatorView3()
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
                .multilineTextAlignment(.center)
                .padding(.top, 112)
                
                Spacer().frame(height: 40) // Reduced height to move the Picker closer to the text
                
                // Dropdown Menu
                Picker("Select your campus", selection: $selectedCampus) {
                    ForEach(campuses, id: \.self) { campus in
                        Text(campus)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.black) // Attempt to apply a global text color
                .frame(width: 300, height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.03, green: 0.75, blue: 0.72), lineWidth: 2)
                )
                .cornerRadius(8)



                Spacer().frame(height: 150) // Increased height to move the button lower on the screen

                // Confirm My Campus Button
                Button(action: {
                    // Handle confirm campus action
                }) {
                    Text("Confirm My Campus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50) // Adjusted size for a bigger button
                        .background(Color(red: 0.03, green: 0.75, blue: 0.72))
                        .cornerRadius(100)
                }
                
                Spacer() // Spacer to push content upwards
            }
            .frame(maxWidth: 480)
            .background(Color.white)
            .cornerRadius(32)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct LocationPermissionView3_Previews: PreviewProvider {
    static var previews: some View {
        LocationPermissionView3()
    }
}

// Progress Indicator View (Updated with Purple Circle in Middle Space)
struct ProgressIndicatorView3: View {
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

