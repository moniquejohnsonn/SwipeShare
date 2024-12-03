import Foundation
import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

struct MealSwipeRequestView: View {
    @State private var navigateToMapView = false // State to trigger navigation
    @State private var showPopup = false // State to control popup visibility
    @State private var confirmationTimer: Timer? = nil // Timer for the delay
    @State private var selectedDiningHall: DiningHall? = nil
    
    @Environment(\.dismiss) private var dismiss // Dismiss environment variable to navigate back
    
    var giver: UserProfile
    var diningHall: DiningHall
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Button(action: {
                                navigateToMapView = true
                                
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .font(.title)
                                    Text("Back")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 70)
                        .padding(.bottom, 10)
                        .background(Constants.LightPurple)
                        
                        // Profile Section
                        HStack {
                            if let profilePictureURL = giver.profilePictureURL {
                                AsyncImage(url: URL(string: profilePictureURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Constants.Turquoise, lineWidth: 4))
                                        .shadow(radius: 10)
                                }
                                placeholder: {
                                    Image("profilePicHolder")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                }
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text(giver.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.DarkPurple)
                                
                                Text("\(giver.year) at \(giver.campus)")
                                    .foregroundColor(Constants.DarkPurple)
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Give Rate and Meals Given Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Give Rate:")
                                    .font(.headline)
                                    .foregroundColor(Constants.DarkPurple)
                                Spacer()
                            }
                            
                            HStack {
                                Text("Meals Given:")
                                    .font(.headline)
                                    .foregroundColor(Constants.DarkPurple)
                                Text("\(giver.mealCount)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.DarkPurple)
                                Spacer()
                            }
                        }
                        .padding()
                        
                        // Availability Section
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(Constants.Turquoise)
                            Text("Currently available to give swipes in ")
                                .font(.body)
                                .foregroundColor(Constants.DarkPurple) +
                            Text(diningHall.name)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.DarkPurple)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Confirmation Box
                        VStack(spacing: 70) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(Constants.Turquoise)
                                .font(.largeTitle)
                            
                            Text("Confirm sending meal swipe request to \(giver.name)?")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Turquoise)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Your request is for ")
                                    .font(.body)
                                    .foregroundColor(Constants.DarkPurple) +
                                Text(diningHall.name)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.DarkPurple)
                            }
                            
                            HStack(spacing: 40) {
                                Button(action: {
                                    // Cancel action
                                    dismiss()
                                }) {
                                    Text("Cancel")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(Constants.DarkPurple)
                                        .cornerRadius(9)
                                }
                                
                                Button(action: {
                                    // Confirm action
                                    confirmationTimer?.invalidate()
                                    confirmationTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                                        showPopup = true
                                    }
                                    sendDefaultMessage()
                                }) {
                                    Text("Confirm")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Constants.DarkPurple)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
                .background(Constants.LightPurple)
                .ignoresSafeArea(edges: .top)
                .navigationDestination(isPresented: $navigateToMapView) {
                    ReceiverHomeView2(selectedDiningHall: $selectedDiningHall)
                }
                
                // Popup Overlay
                if showPopup {
                    VStack {
                        Text("Did you receive your meal swipe from \(giver.name)?")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Turquoise)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                // Handle "Yes" action
                                showPopup = false
                                confirmationTimer?.invalidate()
                            }) {
                                Text("Yes")
                                    .padding()
                                    .frame(maxWidth: 100)
                                    .background(Constants.Turquoise)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                // Handle "No" action
                                showPopup = false
                                confirmationTimer?.invalidate()
                            }) {
                                Text("No")
                                    .padding()
                                    .frame(maxWidth: 100)
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .frame(maxWidth: 300)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 2)
                    .transition(.scale)
                }
            }
            .navigationBarBackButtonHidden(true) // Hide default back button
        }
    }
    func sendDefaultMessage() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let giverName = giver.name
        let diningHallName = diningHall.name
        let messageText = " sent \(giverName) a meal request in \(diningHallName)."
        
        let db = Firestore.firestore()
        
        // Create a new chat document
        let chatRef = db.collection("chats").document() // Generates a new unique ID
        let chatId = chatRef.documentID
        
        // Define chat metadata
        let chatData: [String: Any] = [
            "participants": [userId, giver.id],
            "createdAt": Timestamp(),
            "lastMessage": messageText,
            "lastMessageTimestamp": Timestamp()
        ]
        
        // Define the initial message
        let messageData: [String: Any] = [
            "senderID": userId,
            "content": messageText,
            "timestamp": Timestamp(),
            "type": "initial"
        ]
        
        // Save the chat and the message
        chatRef.setData(chatData) { error in
            if let error = error {
                print("Error creating chat: \(error.localizedDescription)")
                return
            }
            
            chatRef.collection("messages").addDocument(data: messageData) { messageError in
                if let messageError = messageError {
                    print("Error sending message: \(messageError.localizedDescription)")
                } else {
                    print("Chat and message created successfully!")
                }
            }
        }
    }
}


