//
//  ContentView.swift
//  milestone3
//
//  Created by Natalie Bran on 11/11/24.
//

import SwiftUI

struct SettingsView: View {
    // manage the toggle states
    @State private var isActivelyGivingSwipes: Bool = false
    @State private var allowProfileAutoShow: Bool = true
    
    var body: some View {
        ScrollView {
            VStack {
                // Header Section
                ZStack {
                    Constants.Turquoise
                        .frame(height: 150)
                    
                    HStack {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.leading)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Profile Picture and Name
                VStack {
                    Image("rosa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                    
                    Text("Rosa Figueroa")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Purple)
                }
                .padding(.top, -60)
                
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
                        // Change School Action
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
                .background(Constants.LightTurquoise) // Different color background for "My School"
                .cornerRadius(15)
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                Divider().padding(.vertical, 8)
                
                // Role Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Role:")
                        .font(.headline)
                        .foregroundColor(Constants.DarkPurple)
                    
                    Text("Receiver")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.DarkPurple)
                    
                    Button(action: {
                        // Change Role Action
                    }) {
                        Text("Change Role to Giver")
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
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
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
