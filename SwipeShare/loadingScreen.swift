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
            
            Image("LogoIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 400)
            
        }
    }
}

#Preview {
    loadingScreen()
}
