//
//  receiverToGiver.swift
//  SwipeShare
//
//  Created by Monique Johnson on 12/2/24.
//


import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import UIKit

struct receiverToGiver: View {
    @State private var isSwipeGiverChecked = true
    @State private var isSwipeReceiverChecked = false
    @State private var selectedFrequency: String = ""
    @State private var weeklyChecked = false
    @State private var semesterlyChecked = false
    @State private var annuallyChecked = false
    @State private var inputNumber = ""
    @State private var navigateToFinalizeAccount2 = false
    @State private var navigateToReceiverHome = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // Progress Indicator View
                ProgressIndicatorView4()
                    .padding(.top, 70) // Moved up
                
                // Title Text
                VStack(spacing: -50) { // Removed spacing between lines
                    Text("Update Your")
                        .font(.custom("BalooBhaina2-Bold", size: 48))
                        .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                    
                    Text("Profile")
                        .font(.custom("BalooBhaina2-Bold", size: 48))
                        .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                }
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                
                // "Are you a:" Text
                Text("Are you a:")
                    .font(.custom("BalooBhaina2-Bold", size: 30))
                    .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                    .frame(maxWidth: .infinity, alignment: .leading) // Left-aligned
                    .padding(.leading, 46)
                    .padding(.top, 36)
                
                // Swipe Giver and Swipe Receiver Checkboxes
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Swipe Giver")
                            .font(.custom("BalooBhaina2-Regular", size: 22))
                            .frame(width: 150, alignment: .leading)
                        CheckBoxView(
                            isChecked: $isSwipeGiverChecked,
                            label: "Swipe Giver",
                            selectedFrequency: $selectedFrequency,
                            onToggle: { isSwipeReceiverChecked = false }
                        )
                    }
                    
                    HStack {
                        Text("Swipe Receiver")
                            .font(.custom("BalooBhaina2-Regular", size: 22))
                            .frame(width: 150, alignment: .leading)
                        CheckBoxView(
                            isChecked: $isSwipeReceiverChecked,
                            label: "Swipe Receiver",
                            selectedFrequency: $selectedFrequency,
                            onToggle: { isSwipeGiverChecked = false }
                        )
                    }
                }
                .padding(.leading, 16)
                .padding(.top, 8)
                
                // Frequency Checkboxes (only visible if Swipe Giver is selected)
                if isSwipeGiverChecked {
                    VStack(alignment: .leading, spacing: -20) {
                        Text("How many meal")
                            .font(.custom("BalooBhaina2-Bold", size: 30))
                            .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                        
                        Text("swipes do you have?")
                            .font(.custom("BalooBhaina2-Bold", size: 30))
                            .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.82))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 36)
                    .padding(.top, 10)
                    .padding(.bottom, 4)
                    HStack(spacing: 10) {
                        CheckBoxView(isChecked: $weeklyChecked, label: "weekly", selectedFrequency: $selectedFrequency) {
                            semesterlyChecked = false
                            annuallyChecked = false
                        }
                        Text("weekly")
                            .font(.custom("BalooBhaina2-Bold", size: 16))
                        
                        CheckBoxView(isChecked: $semesterlyChecked, label: "semesterly", selectedFrequency: $selectedFrequency) {
                            weeklyChecked = false
                            annuallyChecked = false
                        }
                        Text("semesterly")
                            .font(.custom("BalooBhaina2-Bold", size: 16))
                        
                        CheckBoxView(isChecked: $annuallyChecked, label: "annually", selectedFrequency: $selectedFrequency) {
                            weeklyChecked = false
                            semesterlyChecked = false
                        }
                        Text("annually")
                            .font(.custom("BalooBhaina2-Bold", size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Purple Input Bar (only visible if Swipe Giver is selected)
                    HStack {
                        TextField("Enter a \(selectedFrequency) number", text: $inputNumber)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(Color(red: 0.85, green: 0.82, blue: 0.95).opacity(0.6))
                            .cornerRadius(100)
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 56)
                    .padding(.top, 8)
                }
                
                // Receiver Section - "All Set!" Button
                if isSwipeReceiverChecked {
                    Button(action: {
                        updateProfileForReceiver() // Update profile status as Receiver
                        navigateToReceiverHome = true
                    }) {
                        Text("All Set!")
                            .font(.custom("BalooBhaina2-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 0.03, green: 0.75, blue: 0.72))
                            .cornerRadius(100)
                    }
                    .padding(.top, 20)
                    .navigationDestination(isPresented: $navigateToReceiverHome) {
                        ReceiverHomeView1()
                    }
                }
                
                // Continue Button (only enabled when the form is valid)
                if isSwipeGiverChecked {
                    Button(action: {
                        updateProfileForGiver() // Update profile status as Giver
                        navigateToFinalizeAccount2 = true
                    }) {
                        Text("Last Step")
                            .font(.custom("BalooBhaina2-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background((isSwipeReceiverChecked || (!inputNumber.isEmpty && isSwipeGiverChecked)) ? Color(red: 0.03, green: 0.75, blue: 0.72) : Color.gray)
                            .cornerRadius(100)
                    }
                    .disabled(!isSwipeGiverChecked || inputNumber.isEmpty)
                    .padding(.top, 20)
                    .navigationDestination(isPresented: $navigateToFinalizeAccount2) {
                        FinalizeAccount2(selectedFrequency: $selectedFrequency)
                    }
                }
            }
            .frame(maxWidth: 480)
            .background(Color.white)
            .cornerRadius(32)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
    
    // Update profile for Receiver
    func updateProfileForReceiver() {
        let userID = Auth.auth().currentUser?.uid
        db.collection("users").document(userID!)
            .updateData([
                "isGiver": false
            ]) { error in
                if let error = error {
                    print("Error updating profile for receiver: \(error.localizedDescription)")
                } else {
                    print("Profile updated as Receiver")
                }
            }
    }
    
    // Update profile for Giver
    func updateProfileForGiver() {
        let userID = Auth.auth().currentUser?.uid
        db.collection("users").document(userID!)
            .updateData([
                "isGiver": true,
                "mealFrequency": selectedFrequency,
                "mealCount": inputNumber
            ]) { error in
                if let error = error {
                    print("Error updating profile for giver: \(error.localizedDescription)")
                } else {
                    print("Profile updated as Giver")
                }
            }
    }
    
    // Progress Indicator View
    struct ProgressIndicatorView4: View {
        var body: some View {
            GeometryReader { geometry in
                HStack(alignment: .center, spacing: 20) {
                    Rectangle()
                        .fill(Color(red: 0.85, green: 0.82, blue: 0.95))
                        .frame(width: 108, height: 1)
                    
                    Rectangle()
                        .fill(Color(red: 0.85, green: 0.82, blue: 0.95))
                        .frame(width: 108, height: 1)
                    
                    Circle()
                        .strokeBorder(Color(red: 0.22, green: 0.11, blue: 0.47), lineWidth: 2)
                        .frame(width: 18, height: 18)
                }
                .frame(width: geometry.size.width, alignment: .center)
            }
            .frame(height: 20)
        }
    }
    
    // CheckBox View
    struct CheckBoxView: View {
        @Binding var isChecked: Bool
        let label: String
        @Binding var selectedFrequency: String
        var onToggle: () -> Void = {}
        
        var body: some View {
            Button(action: {
                isChecked.toggle()
                if isChecked {
                    selectedFrequency = label
                    onToggle() // Uncheck the other checkboxes
                }
            }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? Color(red: 0.03, green: 0.75, blue: 0.72) : .gray)
                    .font(.system(size: 24))
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
}

#Preview {
    receiverToGiver()
}
