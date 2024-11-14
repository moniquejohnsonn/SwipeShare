import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct loginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @Binding var isAuthenticated: Bool
    @State private var navigateToForgotEmail = false
    @State private var navigateToSignUp = false
    @State private var navigateToGiverHome = false
    @State private var navigateToReceiverHome = false
    
    @State private var userRole: String? = nil
    
    var body: some View {
        VStack {
            
            Text("Login")
                .font(.custom("BalooBhaina2-Bold", size:45))
                .foregroundColor(Color(red: 131 / 255, green: 50 / 255, blue: 172 / 255))
            
            Spacer().frame(height: 40)
            
            TextField("email", text: $email)
                .padding()
                .background(Color(red: 202 / 255, green: 168 / 255, blue: 245 / 255).opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .autocapitalization(.none)
            
            SecureField("password", text: $password)
                .padding()
                .background(Color(red: 202 / 255, green: 168 / 255, blue: 245 / 255).opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            
            HStack {
                Spacer()
                // TODO: - Forgot Password Link Sending
                Button(action: {
                    // Forgot password action
                    forgotPassword()
                }) {
                    Text("Forgot Password?")
                        .font(.footnote)
                        .foregroundColor(.blue)
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
                    .background(Color.blue)
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
                    .foregroundColor(.gray)
                
                Button(action: {
                    navigateToSignUp = true
                }) {
                    Text("Sign Up")
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Log In")
        .navigationDestination(isPresented: $navigateToSignUp) {
            SignUpView(isAuthenticated: $isAuthenticated)
        }
        .navigationDestination(isPresented: $navigateToGiverHome) {
            GiverHomeView()
        }
        .navigationDestination(isPresented: $navigateToReceiverHome) {
            ReceiverHomeView()
        }
    }
    
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = nil
                self.isAuthenticated = true
                fetchProfile()
            }
        }
    }
    
    private func fetchProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        
        // Fetch the user document from Firestore
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                // Extract the role booleans from the document
                let isGiver = document.get("isGiver") as? Bool ?? false
                let isReceiver = document.get("isReceiver") as? Bool ?? false
                
                // Navigate based on role
                if isGiver {
                    navigateToGiverHome = true
                } else if isReceiver {
                    navigateToReceiverHome = true
                } else {
                    errorMessage = "Error: User role not found."
                }
            } else {
                // Handle the error if the document doesn't exist or fetch failed
                errorMessage = "Error fetching profile: \(error?.localizedDescription ?? "Unknown error")"
            }
        }
    }
    
    // Forgot email functionality
    private func forgotPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = "Password reset email sent."
            }
        }
    }
}

#Preview {
    loginView(isAuthenticated: .constant(false))
}
