import SwiftUI

struct StartUpView: View {
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        ZStack {
            Color(red: 0.027, green: 0.745, blue: 0.722)
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
                NavigationLink(destination: SignUpView(isAuthenticated: $isAuthenticated)) {
                    Text("Sign Up")
                        .font(.custom("BalooBhaina2-Bold", size: 20))
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 20)
                        .background(Color(red: 0.29, green: 0.051, blue: 0.404))
                        .cornerRadius(100)
                        .padding(.horizontal, 10)
                }
                
                // "Already have an account?" Text and Log In Link
                HStack {
                    Text("Already have an account? ")
                        .font(.custom("BalooBhaina2-Medium", size: 16))
                        .foregroundColor(.white)
                    
                    NavigationLink(destination: loginView(isAuthenticated: $isAuthenticated)) {
                        Text("Log In")
                            .font(.custom("BalooBhaina2-Medium", size: 16))
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding(.top, 20) // Add some space between the SignUp button and this text
                Spacer().frame(height: 40) // Space at the bottom
            }
        }
    }
}

#Preview {
    StartUpView(isAuthenticated: .constant(false))
}
