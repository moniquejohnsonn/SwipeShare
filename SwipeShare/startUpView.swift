import SwiftUI

struct StartUpView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var isSignUp = false
    @State private var isLogIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("primaryGreen")
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Logo Image
                    Image("LogoIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 350)
                    
                    Spacer()
                    
                    // Sign Up Button
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .font(.custom("BalooBhaina2-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 20)
                            .background(Color("primaryPurple"))
                            .cornerRadius(100)
                            .padding(.horizontal, 10)
                    }
                    
                    // "Already have an account?" Text and Log In Link
                    HStack {
                        Text("Already have an account? ")
                            .font(.custom("BalooBhaina2-Medium", size: 16))
                            .foregroundColor(.white)
                        
                        NavigationLink(destination: loginView()) {
                            Text("Log In")
                                .font(.custom("BalooBhaina2-Medium", size: 16))
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .padding(.top, 20) // Add some space between the SignUp button and this text
                    Spacer().frame(height: 40) // Space at the bottom
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    StartUpView()
}
