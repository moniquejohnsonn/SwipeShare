import SwiftUI
import Foundation

struct LocationPermissionView3: View {
    @State private var isLoading = true
    @State private var selectedSchool: School? = nil
    // initialize to mock schools for testing in canvas
    @State private var schools: [School] = [
        School(properties: SchoolProperties(name: "Columbia University", city: "New York", postcode: "10027"), geometry: Geometry(coordinates: [-73.9626, 40.8075])),
        School(properties: SchoolProperties(name: "NYU", city: "New York", postcode: "10003"), geometry: Geometry(coordinates: [-73.9980, 40.7295]))
    ]
    
    private let apiService = APIService() // creates an instance of APIService

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
                
                // Loading indicator or Picker
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    // School Picker
                    Picker("Select your campus", selection: $selectedSchool) {
                        Text("Select your school")
                            .tag(nil as School?)
                        
                        ForEach(schools) { school in
                            Text(school.properties.name ?? "Unknown")
                                .tag(school as School?)
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
                }
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
        .onAppear {
            fetchSchools()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
    
    // Fetch Schools Function
    func fetchSchools() {
        print("fetching")
        apiService.fetchUsers { result in
            switch result {
            case .success(let fetchedSchools):
                schools.append(contentsOf: fetchedSchools)
                isLoading = false
            case .failure(let error):
                print("Error fetching schools: \(error)")
                isLoading = false
            }
        }
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

