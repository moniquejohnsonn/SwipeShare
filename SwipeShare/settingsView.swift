import SwiftUI

struct SettingsView: View {
    // manage the toggle states
    @ObservedObject var userProfileManager = UserProfileManager()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isActivelyGivingSwipes: Bool = false
    @State private var allowProfileAutoShow: Bool = true
    @State private var showSidebar = false
    @State private var signedOut = false
    @State private var navigateToGiverOnboarding: Bool = false // New navigation state
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    // Header Section
                    ZStack {
                        Constants.Turquoise
                            .frame(height: 150)
                        
                        HStack {
                            Button(action: {
                                withAnimation {
                                    showSidebar.toggle()
                                }
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(.leading)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Text("Settings")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Profile Picture and Name
                    if let userProfile = userProfileManager.currentUserProfile {
                        VStack {
                            AsyncImage(url: URL(string: userProfile.profilePictureURL ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 10)
                            } placeholder: {
                                if ((userProfile.profilePictureURL?.isEmpty) != nil) {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .shadow(radius: 10)
                                } else {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .shadow(radius: 10)
                                }
                            }
                            
                            Text(userProfile.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Purple)
                        }
                        .padding(.top, -60)
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    // School Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("My School:")
                            .font(.headline)
                            .foregroundColor(Constants.Purple)
                        
                        HStack {
                            Image("columbia")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .padding(.trailing, 8)
                            Text("Columbia University")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Purple)
                        }
                        
                        Button(action: {
                            // TODO: Change School Action
                        }) {
                            Text("Change Schools")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Constants.Purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Constants.LightTurquoise)
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Divider().padding(.vertical, 8)
                    
                    // Role Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Role:")
                            .font(.headline)
                            .foregroundColor(Constants.DarkPurple)
                        
                        Text(userProfileManager.currentUserProfile?.isGiver == true ? "Giver" : "Receiver")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.DarkPurple)
                        
                        Button(action: {
                            if var userProfile = userProfileManager.currentUserProfile {
                                userProfile.isGiver.toggle() // Toggle the role
                                
                                // Update the profile in UserProfileManager
                                userProfileManager.currentUserProfile = userProfile
                                
                                // Save the updated profile to Firestore
                                userProfileManager.saveUserProfile(profile: userProfile) { error in
                                    if let error = error {
                                        print("Error saving user profile: \(error.localizedDescription)")
                                    } else {
                                        print("User profile updated successfully!")
                                        
                                        // Navigate to Giver Onboarding if role is set to Giver
                                        if userProfile.isGiver {
                                            navigateToGiverOnboarding = true
                                        }
                                    }
                                }
                              
                            }
                            
                        }) {
                            Text(userProfileManager.currentUserProfile?.isGiver == true ? "Change Role to Receiver" : "Change Role to Giver")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Constants.DarkPurple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Constants.LightPurple)
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Divider().padding(.vertical, 8)
                    
                    
                    if userProfileManager.currentUserProfile?.isGiver == true {
                        // Toggle Buttons
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: $isActivelyGivingSwipes) {
                                Text("Actively giving swipes")
                                    .padding(.trailing, 10)
                                    .font(.body)
                                    .foregroundColor(Constants.DarkPurple)
                            }
                            .padding(.horizontal)
                            .tint(Constants.DarkPurple)
                            
                            Toggle(isOn: $allowProfileAutoShow) {
                                Text("Allow profile to automatically be shown to receivers when in a dining hall")
                                    .padding(.trailing, 10)
                                    .font(.body)
                                    .foregroundColor(Constants.DarkPurple)
                            }
                            .padding(.horizontal)
                            .tint(Constants.DarkPurple)
                        }
                    }
                    
                    // Sign Out Button
                    Button(action: {
                        userProfileManager.signOut()
                        signedOut = true
                    }) {
                        Text("Sign Out")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(edges: .top)
            .navigationDestination(isPresented: $signedOut) {
                StartUpView()
            }
            .navigationDestination(isPresented: $navigateToGiverOnboarding) {
                receiverToGiver() // Navigate to the Giver Onboarding view
            }
            
            // sidebar content
            MenuView(isSidebarVisible: $showSidebar)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.move(edge: .leading))
                .padding(.leading, 0)
        }
        .navigationBarBackButtonHidden(true)
    }
      
}

struct Constants {
    static let Turquoise: Color = Color(red: 0.03, green: 0.75, blue: 0.72)
    static let LightTurquoise: Color = Color(red: 0.65, green: 0.90, blue: 0.87)
    static let Purple: Color = Color(red: 0.4, green: 0.0, blue: 0.6)
    static let LightPurple: Color = Color(red: 0.85, green: 0.75, blue: 0.95)
    static let DarkPurple: Color = Color(red: 0.3, green: 0.0, blue: 0.5)
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

#Preview {
   
}
