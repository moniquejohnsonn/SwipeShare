import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct Chat: Identifiable, Decodable {
    @DocumentID var id: String?
    let participants: [String]
    let createdAt: Timestamp
    let lastMessage: String
    let lastMessageTimestamp: Timestamp
    let profilePicture: String?
    var name: String
    
    var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: lastMessageTimestamp.dateValue())
        
        let calendar = Calendar.current
        let today = calendar.isDateInToday(lastMessageTimestamp.dateValue())
        
        if today {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: lastMessageTimestamp.dateValue())
        } else {
            formatter.dateFormat = "MMM dd"
            return formatter.string(from: lastMessageTimestamp.dateValue())
        }
    }
}

enum CodingKeys: String, CodingKey {
    case id, participants, createdAt, lastMessage, lastMessageTimestamp, profilePicture
}

struct ChatListView: View {
    @State private var showSidebar = false
    @State private var chats = [Chat]()
    @State private var selectedChat: Chat? = nil
    @State private var isLoading = true
    @StateObject private var userProfileManager = UserProfileManager()
    
    private var db = Firestore.firestore()
    
    // Fetch the chats where the user is a participant
    func fetchChats() {
        isLoading = true
        
        guard let userId = userProfileManager.currentUserProfile?.id else {
            print("User ID is nil. Exiting fetchChats.")
            return
        }
        
        print("Fetching chats for user ID: \(userId)")
        
        db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .getDocuments { snapshot, error in
                self.isLoading = false
                if let error = error {
                    print("Error fetching chats: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.chats = []
                let dispatchGroup = DispatchGroup() // To handle async calls for fetching user details
                
                for document in documents {
                    let data = document.data()
                    let chatID = document.documentID
                    let participants = data["participants"] as? [String] ?? []
                    let lastMessage = data["lastMessage"] as? String ?? ""
                    let lastMessageTimestamp = data["lastMessageTimestamp"] as? Timestamp ?? Timestamp()
                    
                    // Determine the other participant
                    let otherUserID = participants.first { $0 != Auth.auth().currentUser?.uid }
                    
                    // Fetch the other user's name and profilePictureURL
                    if let otherUserID = otherUserID {
                        dispatchGroup.enter()
                        db.collection("users").document(otherUserID).getDocument { userSnapshot, userError in
                            if let userError = userError {
                                print("Error fetching user details: \(userError.localizedDescription)")
                            } else if let userData = userSnapshot?.data() {
                                let userName = userData["name"] as? String ?? "Unknown"
                                let userProfilePictureURL = userData["profilePictureURL"] as? String ?? ""
                                
                                // Create Chat object with the other user's name and profile picture URL
                                let chat = Chat(
                                    id: chatID,
                                    participants: participants,
                                    createdAt: data["createdAt"] as? Timestamp ?? Timestamp(),
                                    lastMessage: lastMessage,
                                    lastMessageTimestamp: lastMessageTimestamp,
                                    profilePicture: userProfilePictureURL,
                                    name: userName
                                )
                                self.chats.append(chat)
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                
                // Update the UI after all user details are fetched
                dispatchGroup.notify(queue: .main) {
                    self.chats.sort { $0.lastMessageTimestamp.dateValue() > $1.lastMessageTimestamp.dateValue() }
                }
            }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack {
                    if isLoading {
                        // Loading Indicator
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.top, 60) // Adjust for header height
                    } else if chats.isEmpty {
                        // No Chats Message
                        VStack {
                            Text("No chats available.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 60) // Adjust for header height
                    } else {
                        // Chat List
                        List(chats) { chat in
                            NavigationLink(
                                destination: ChatDetailView(chat: chat),
                                label: {
                                    HStack(spacing: 15) {
                                        if let profilePicture = chat.profilePicture {
                                            AsyncImage(url: URL(string: profilePicture)) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                            } placeholder: {
                                                Image("profilePicHolder")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                            }
                                        } else {
                                            Image("profilePicHolder")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(chat.name)
                                                .font(.headline)
                                                .foregroundColor(.black)
                                            
                                            Text(chat.lastMessage)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(chat.timestamp)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 10)
                                }
                            )
                        }
                        .listStyle(PlainListStyle())
                        .padding(.top, 150)
                    }
                }
                
                // Header View
                HeaderView(
                    title: "Chats",
                    showBackButton: false,
                    onHeaderButtonTapped: {
                        withAnimation {
                            showSidebar.toggle() // Toggle sidebar visibility
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .background(Color.white)
                
                // Sidebar Menu
                MenuView(isSidebarVisible: $showSidebar)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.move(edge: .leading))
            }
            .edgesIgnoringSafeArea([.top, .bottom])
            .onAppear {
                userProfileManager.fetchUserProfile {
                    if let _ = userProfileManager.currentUserProfile {
                        fetchChats()
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}

