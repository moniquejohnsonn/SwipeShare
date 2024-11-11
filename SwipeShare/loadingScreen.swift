//
//  loadingScreen.swift
//  SwipeShare
//
//  Created by Monique Johnson on 11/10/24.
//

import SwiftUI

struct loadingScreen: View {
    var body: some View {
        ZStack {
            Color(red: 0.027, green: 0.745, blue: 0.722).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("LogoIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 400)
                
                Spacer()
                
                Text("Loading...")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                Spacer()
            }
        }
    }
}

#Preview {
    loadingScreen()
}
