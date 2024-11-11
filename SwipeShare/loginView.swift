//
//  loginView.swift
//  SwipeShare
//
//  Created by Monique Johnson on 11/10/24.
//

import SwiftUI
import FirebaseAuth

struct loginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @Binding var isAuthenticated: Bool
    
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
            
            SecureField("password", text: $password)
                .padding()
                .background(Color(red: 202 / 255, green: 168 / 255, blue: 245 / 255).opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            
            HStack {
                Spacer()
                // TODO: - Forgot Email Link Sending
                Text("Forgot Email?")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.trailing, 24)
                    .padding(.top, 8)
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
                    // TODO: - Sign Up Button Action
                }) {
                    Text("Sign Up")
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Log In")
    }
    
    private func loginUser() {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.errorMessage = nil
                    self.isAuthenticated = true
                }
            }
        }
    }

#Preview {
    loginView(isAuthenticated: .constant(false))
}
