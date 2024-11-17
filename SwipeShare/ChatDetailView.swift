import SwiftUI
import FirebaseFirestore

struct ChatDetailView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.presentationMode) var presentationMode // For back navigation
    @State private var newMessage: String = "" // For typing new messages
    
    
    // The chat selected from ChatListView
    let chat: Chat
    @State private var messages: [Message] = [] // Array of optional Message
    
    // Firestore reference to messages
    private var db = Firestore.firestore()
    
    init(chat: Chat) {
        self.chat = chat
    }
    
    func loadMessages() {
        db.collection("chats")
            .document(chat.id ?? "") // Use optional unwrapping to ensure chat.id is not nil
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                // Clear previous messages before loading new ones
                var loadedMessages: [Message] = []
                
                // Loop through documents and manually validate before appending valid messages
                querySnapshot?.documents.forEach { document in
                    let data = document.data()
                    
                    // Safely extract values from the Firestore document
                    guard let content = data["content"] as? String,
                          let senderId = data["senderId"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        print("Document data is missing required fields: \(document.documentID)")
                        return // Skip this document if required fields are missing
                    }
                    
                    let isFromCurrentUser = senderId == self.userProfileManager.currentUserProfile?.id
                    let message = Message(id: document.documentID, content: content, isFromCurrentUser: isFromCurrentUser, timestamp: timestamp.dateValue())
                    
                    // Append valid message to the list
                    loadedMessages.append(message)
                }
                
                // Assign the filtered messages array to state
                self.messages = loadedMessages
            }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                        Text("Back to Chats")
                            .foregroundColor(.white)
                            .font(.custom("BalooBhaina2-Bold", size: 16))
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 10) {
                    if let profilePicture = chat.profilePicture {
                        Image(profilePicture)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                    
                    Text(chat.name)
                        .font(.custom("BalooBhaina2-Bold", size: 24))
                        .foregroundColor(.white)
                }
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.027, green: 0.745, blue: 0.722))
            
            // Messages List
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isFromCurrentUser {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Color("lightestPurple").opacity(0.6))
                                    .foregroundColor((Color("primaryPurple")))
                                    .cornerRadius(10)
                                    .frame(maxWidth: 250, alignment: .trailing)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color("secondaryGreen").opacity(0.8))
                                    .cornerRadius(10)
                                    .frame(maxWidth: 250, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.white)
            
            // Input Area
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("primaryPurple"))
                        .clipShape(Circle())
                }
                .disabled(newMessage.isEmpty)
            }
            .padding()
            .background(Color.white)
        }
        .onAppear {
            loadMessages() // Load messages when the view appears
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // Send a new message to Firestore
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        guard let userId = userProfileManager.currentUserProfile?.id else {
            print("User is not logged in")
            return
        }
        
        let messageData: [String: Any] = [
            "content": newMessage,
            "senderId": userId,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // Add message to Firestore
        db.collection("chats")
            .document(chat.id ?? "")
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    // Clear the input field and reload messages
                    newMessage = ""
                }
            }
    }
}


// Message Model
struct Message: Identifiable {
    var id: String
    var content: String
    var isFromCurrentUser: Bool
    var timestamp: Date
}

