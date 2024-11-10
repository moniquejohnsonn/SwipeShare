//
//  SwiftUIView.swift
//  SwipeShare
//
//  Created by Monique Johnson on 11/10/24.
//

import SwiftUI

struct homeView: View {
    var body: some View {
        ZStack {
            Color(red: 0.027, green: 0.745, blue: 0.722)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("LogoIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                
                Spacer()
                
                // Sign Up Button
                Button(action: {
                    // MARK: - Sign Up Button Action
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 20)
                        .background(Color(red: 0.29, green: 0.051, blue: 0.404))
                        .cornerRadius(100)
                        .padding(.horizontal, 10)
                }
                // Login Text
                HStack{
                    Text("Already have an account? ")
                        .foregroundColor(.white)
                    Text("Log In")
                        .foregroundColor(.white)
                        .underline()
                        .onTapGesture {
                            // MARK: - Log In Text Action
                        }
                }
                Spacer().frame(height: 40)
            }
        }
    }
}

#Preview {
    homeView()
}
