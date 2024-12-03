import SwiftUI
import FirebaseFirestore

struct ChatDetailView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.presentationMode) var presentationMode // For back navigation
    @State private var newMessage: String = "" // For typing new messages
    @State private var showSidebar = false
    
    // The chat selected from ChatListView
    let chat: Chat
    @State private var messages: [Message] = [] // Array of optional Message
    
    // Firestore reference to messages
    private var db = Firestore.firestore()
    
    @State private var lastMessageId: String?
    
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
                    
                    // Debug: Print the document data
                    print("Document data: \(data)")
                    
                    guard let content = data["content"] as? String,
                          let senderId = data["senderID"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp,
                          let type = data["type"] as? String else {
                        print("Document data is missing required fields: \(document.documentID)")
                        return // Skip this document if required fields are missing
                    }
                    
                    let isFromCurrentUser = senderId == self.userProfileManager.currentUserProfile?.id
                    let message = Message(id: document.documentID, content: content, isFromCurrentUser: isFromCurrentUser, timestamp: timestamp.dateValue(), type: type)
                    
                    // Append valid message to the list
                    loadedMessages.append(message)
                }
                
                // Debug: Check the loaded messages
                // print("Loaded messages: \(loadedMessages)")
                
                // Assign the filtered messages array to state
                self.messages = loadedMessages
                
                self.lastMessageId = loadedMessages.last?.id
            }
    }
    
    struct HeaderView: View {
        @Environment(\.presentationMode) var presentationMode
        let chat: Chat
        
        var body: some View {
            VStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                    }
                    Spacer()
                }
                .padding()
                
                VStack(spacing: 10) {
                    if let profilePictureURL = chat.profilePicture {
                        AsyncImage(url: URL(string: profilePictureURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } placeholder: {
                            Image("profilePicHolder")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        }
                    } else {
                        Image("profilePicHolder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                    
                    Text(chat.name)
                        .font(.custom("BalooBhaina2-Bold", size: 24))
                        .foregroundColor(.white)
                }
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.027, green: 0.745, blue: 0.722))
        }
    }
    
    struct MessageBubbleView: View {
        let chat: Chat
        let message: ChatDetailView.Message
        
        var body: some View {
            HStack {
                if message.type == "initial" {
                    Spacer()
                    if message.isFromCurrentUser {
                        Text("You" + message.content)
                            .padding()
                            .background(Color("initialChat"))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .frame(maxWidth: 250, alignment: .trailing)
                    }
                    else {
                        Text(chat.name + message.content)
                            .padding()
                            .background(Color("initialChat"))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .frame(maxWidth: 250, alignment: .leading)
                    }
                } else {
                    if message.isFromCurrentUser {
                        Spacer()
                        Text(message.content)
                            .padding()
                            .background(Color("lightestPurple").opacity(0.6))
                            .foregroundColor(Color("primaryPurple"))
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
    }
    
    struct MessagesListView: View {
        let chat: Chat
        let messages: [ChatDetailView.Message]
        
        var body: some View {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { message in
                            MessageBubbleView(chat: chat, message: message)
                                .id(message.id) // Ensure unique IDs for scrolling
                        }
                    }
                    .padding()
                    .onAppear {
                        // Scroll to the bottom when messages are loaded
                        if let lastMessage = messages.last {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .background(Color.white)
            }
        }
    }
    
    struct InputAreaView: View {
        @Binding var newMessage: String
        let sendMessage: () -> Void
        
        var body: some View {
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
    }
    
    var body: some View {
        ZStack {
            // Menu View (Sidebar)
            if showSidebar {
                MenuView(isSidebarVisible: $showSidebar)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.move(edge: .leading))
                    .padding(.leading, 0)
            }
            
            VStack(spacing: 0) {
                HeaderView(chat: chat)
                
                MessagesListView(chat: chat, messages: messages)
                
                InputAreaView(newMessage: $newMessage, sendMessage: sendMessage)
            }
            .onAppear {
                loadMessages() // Load messages when the view appears
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
        }
    }
    
    // Send a new message to Firestore
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        guard let userId = userProfileManager.currentUserProfile?.id else {
            print("User is not logged in")
            return
        }
        
        // Save message data to Firestore
        let messageData: [String: Any] = [
            "content": newMessage,
            "senderID": userId,
            "timestamp": FieldValue.serverTimestamp(),
            "type": "message"
        ]
        
        let chatDB = db.collection("chats").document(chat.id ?? "")
        
        chatDB
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                    // Optionally handle failed Firestore write (e.g., show an error to the user)
                } else {
                    print("Message sent successfully")
                }
            }
        
        let chatUpdateData: [String: Any] = [
            "lastMessage": self.newMessage,
            "lastMessageTimestamp": FieldValue.serverTimestamp()
        ]
        
        chatDB.updateData(chatUpdateData) { error in
            if let error = error {
                print("Error updating chat last message: \(error.localizedDescription)")
            } else {
                print("Chat last message updated successfully")
            }
        }
        
        // Clear the input field
        newMessage = ""
        
        // Update the UI with new messages
        loadMessages()
    }
    
    
    // Message Model
    struct Message: Identifiable {
        var id: String
        var content: String
        var isFromCurrentUser: Bool
        var timestamp: Date
        var type: String
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        // Mock Timestamp for lastMessageTimestamp
        let timestamp = Timestamp(date: Date()) // Use current time for testing
        
        // Mock Chat Data
        let mockChat = Chat(
            id: "mockChatId",
            participants: ["user1", "user2"],
            createdAt: timestamp,
            lastMessage: "Hello, how are you?",
            lastMessageTimestamp: timestamp,
            profilePicture: "https://example.com/profile.jpg",
            name: "John Doe"
        )
        
        // Mock UserProfile Data
        let mockUserProfile = UserProfile(
            id: "currentUserId",
            name: "Jane Smith",
            profilePictureURL: "https://example.com/jane.jpg",
            profilePicture: UIImage(named: "profilePicHolder"),
            email: "jane.smith@example.com",
            campus: "CampusName",
            year: "Senior",
            major: "Computer Science",
            numSwipes: 10,
            mealFrequency: "Weekly",
            mealCount: 5,
            isGiver: true
        )
        
        // Mock UserProfileManager
        let mockUserProfileManager = UserProfileManager()
        mockUserProfileManager.currentUserProfile = mockUserProfile
        
        // Return the ChatDetailView with mock data
        return ChatDetailView(chat: mockChat)
            .environmentObject(mockUserProfileManager)
    }
}
