import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct loginView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var navigateToForgotEmail = false
    @State private var navigateToSignUp = false
    @State private var navigateToGiverHome = false
    @State private var navigateToReceiverHome = false
    
    @State private var userRole: String? = nil
    
    var body: some View {
        VStack {
            
            Text("Login")
                .font(.custom("BalooBhaina2-Bold", size:45))
                .foregroundColor(Color("primaryPurple"))
            
            Spacer().frame(height: 40)
            
            TextField("email", text: $email)
                .padding()
                .background(Color("secondaryPurple").opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .autocapitalization(.none)
            
            SecureField("password", text: $password)
                .padding()
                .background(Color("secondaryPurple").opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            
            HStack {
                Spacer()
                Button(action: forgotPassword) {
                    Text("Forgot Password?")
                        .font(.footnote)
                        .foregroundColor(Color("primaryPurple"))
                        .padding(.trailing, 24)
                        .padding(.top, 8)
                }
            }
            
            Button(action: loginUser) {
                Text("Log In")
                    .font(.custom("BalooBhaina2-Bold", size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("primaryGreen"))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(Color("primaryPurple"))
                
                NavigationLink("Sign Up", destination: SignUpView())
                    .foregroundColor(Color("primaryPurple"))
                    .underline()
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Log In")
        .navigationDestination(isPresented: $navigateToGiverHome) {
            GiverHomeView()
        }
        .navigationDestination(isPresented: $navigateToReceiverHome) {
            ReceiverHomeView1()
        }
    }
    
    private func loginUser() {
        userProfileManager.login(email: email, password: password) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let profile = userProfileManager.currentUserProfile {
                errorMessage = nil
                navigateBasedOnRole(profile: profile)
            } else {
                errorMessage = "Failed to fetch user profile."
            }
        }
    }
    
    private func navigateBasedOnRole(profile: UserProfile) {
        if profile.isGiver {
            navigateToGiverHome = true
        } else {
            navigateToReceiverHome = true
        }
    }
    
    private func forgotPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Password reset email sent."
            }
        }
    }
}

#Preview {
    loginView()
}
