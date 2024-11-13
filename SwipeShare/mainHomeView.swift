//
//  receiverHomeView.swift
//  SwipeShare
//
//  Created by Rosa Figueroa on 11/12/24.
//

import SwiftUI

struct MainHomeView: View {
    @State private var isSwipeGiver = false // Toggle this to switch between views
    @State private var isSwipeGiverChecked = false

    var body: some View {
        NavigationView {
            VStack {
                if isSwipeGiver {
                    GiverHomeView()
                } else {
                    ReceiverHomeView(isSwipeGiverChecked: $isSwipeGiverChecked)
                }
                
                // Button to toggle between Giver and Receiver for testing
                Button(action: {
                    isSwipeGiver.toggle()
                }) {
                    Text("Toggle User Type")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
}

struct MainHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView()
    }
}



