import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

struct CampusPermissionView: View {
    @State private var isLoading = true
    @State private var selectedSchool: School? = nil
    @State private var selectedYear = "Select your year" // Default selection
    @State private var selectedMajor = "Select your major" // Default selection
    @State private var navigateToFinalizeAccount = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // Initialize mock schools for testing in Canvas
    @State private var schools: [School] = []
    
    private let apiService = APIService() // Creates an instance of APIService
    private let years = [
        "Select your year", // Placeholder option
        "Freshman",
        "Sophomore",
        "Junior",
        "Senior",
        "Graduate"
    ]
    
    private let majors = [
        "African American and African Diaspora Studies",
        "American Studies",
        "Analytics",
        "Ancient Studies",
        "Anthropology",
        "Applied Mathematics",
        "Applied Mathematics",
        "Applied Physics",
        "Archaeology",
        "Architecture",
        "Art History",
        "Art History and Visual Arts",
        "Astronomy",
        "Astrophysics",
        "Biochemistry",
        "Biology",
        "Biomedical Engineering",
        "Biophysics",
        "Chemical Engineering",
        "Chemical Physics",
        "Chemistry",
        "Civil Engineering",
        "Classical Studies",
        "Classics",
        "Climate System Science",
        "Climate and Sustainability",
        "Cognitive Science",
        "Comparative Literature and Society",
        "Computational Biology",
        "Computer Engineering",
        "Computer Science",
        "Computer Science-Mathematics",
        "Creative Writing",
        "Dance",
        "Data Science",
        "Drama and Theatre Arts",
        "Earth Science",
        "Earth and Environmental Engineering",
        "East Asian Studies",
        "Economics",
        "Economics-Mathematics",
        "Economics-Philosophy",
        "Economics-Political Science",
        "Economics-Statistics",
        "Electrical Engineering",
        "Engineering Management Systems",
        "Engineering Mechanics",
        "English",
        "Environmental Biology",
        "Environmental Chemistry",
        "Environmental Science",
        "Ethnicity and Race Studies",
        "Evolutionary Biology of the Human Species",
        "Film and Media Studies",
        "Financial Economics",
        "Financial Engineering",
        "French",
        "French and Francophone Studies",
        "German Literature and Cultural History",
        "Hispanic Studies",
        "History",
        "History and Theory of Architecture",
        "Human Rights",
        "Industrial Engineering",
        "Information Science",
        "Italian",
        "Latin American and Caribbean Studies",
        "Linguistics",
        "Materials Science and Engineering",
        "Mathematics",
        "Mathematics-Statistics",
        "Mechanical Engineering",
        "Medical Humanities",
        "Middle Eastern, South Asian and African Studies",
        "Music",
        "Neuroscience and Behavior",
        "Operations Research",
        "Philosophy",
        "Physics",
        "Political Science",
        "Political Science-Statistics",
        "Psychology",
        "Regional Studies",
        "Religion",
        "Russian Language and Culture",
        "Russian Literature and Culture",
        "Select your major", // Placeholder option
        "Slavic Studies",
        "Sociology",
        "Statistics",
        "Sustainable Development",
        "Urban Studies",
        "Visual Arts",
        "Women's and Gender Studies",
        "Yiddish Studies"
    ]
    
    
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
                    .foregroundColor(.black)
                    .frame(width: 300, height: 50)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.03, green: 0.75, blue: 0.72), lineWidth: 2)
                    )
                    .cornerRadius(8)
                }
                
                Spacer().frame(height: 20)
                
                // Year Picker
                Picker("Select your year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(year)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 300, height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.03, green: 0.75, blue: 0.72), lineWidth: 2)
                )
                .cornerRadius(8)
                
                Spacer().frame(height: 20)
                
                // Major Picker
                Picker("Select your major", selection: $selectedMajor) {
                    ForEach(majors, id: \.self) { major in
                        Text(major)
                    }
                }
                .pickerStyle(MenuPickerStyle())
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
                    if let selectedCampus = selectedSchool, selectedYear != "Select your year", selectedMajor != "Select your major" {
                        navigateToFinalizeAccount = true
                        updateCampusInFirestore(selectedCampus: selectedCampus, selectedYear: selectedYear, selectedMajor: selectedMajor)
                    } else {
                        showErrorAlert = true
                        errorMessage = "Please complete all fields before proceeding."
                    }
                }) {
                    Text("Confirm My Campus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50) // Adjusted size for a bigger button
                        .background(Color(red: 0.03, green: 0.75, blue: 0.72))
                        .cornerRadius(100)
                }
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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
        .navigationDestination(isPresented: $navigateToFinalizeAccount) {
            FinalizeAccount1()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // Fetch Schools Function
    func fetchSchools() {
        print("Fetching schools...")
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

// Update the campus data in Firestore
func updateCampusInFirestore(selectedCampus: School, selectedYear: String, selectedMajor: String) {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    
    let db = Firestore.firestore()
    
    // Prepare data to update
    let updatedData: [String: Any] = [
        "campus": selectedCampus.properties.name ?? "",
        "year": selectedYear,
        "major": selectedMajor
    ]
    
    // Update the user's Firestore document
    db.collection("users").document(userId).updateData(updatedData) { error in
        if let error = error {
            print("Error updating campus: \(error.localizedDescription)")
        } else {
            print("Campus updated successfully.")
        }
    }
}

struct CampusPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        CampusPermissionView()
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

