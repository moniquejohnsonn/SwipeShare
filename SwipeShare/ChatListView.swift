import SwiftUI
import FirebaseFirestore

struct Chat: Identifiable, Decodable {
    @DocumentID var id: String?
    let participants: [String]
    let createdAt: Timestamp
    let lastMessage: String
    let lastMessageTimestamp: Timestamp
    let profilePicture: String?

    var name: String {
        return "Chat with \(participants.joined(separator: ", "))"
    }

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

    enum CodingKeys: String, CodingKey {
        case id, participants, createdAt, lastMessage, lastMessageTimestamp, profilePicture
    }
}

struct ChatListView: View {
    @State private var showSidebar = false
    @State private var chats = [Chat]()
    @State private var selectedChat: Chat? = nil
    @State private var isLoading = true
    @StateObject private var userProfileManager = UserProfileManager()
    
    private var db = Firestore.firestore()
    
    // TODO: FIX!!!!!
    // Make Nvigation on top and actually pull chats from the database
    
    // Fetch the chats where the user is a participant
    func fetchChats() {
        guard let userId = userProfileManager.currentUserProfile?.id else {
            print("User ID is nil. Exiting fetchChats.")
            return
        }
        
        print("Fetching chats for user ID: \(userId)")
        
        db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "lastMessageTimestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching chats: \(error)")
                    return
                }
                
                self.chats = snapshot?.documents.compactMap { document in
                    try? document.data(as: Chat.self)
                } ?? []
                self.isLoading = false
            }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Custom Header
                        HeaderView(
                            title: "Chats",
                            showBackButton: false,
                            onHeaderButtonTapped: {
                                withAnimation {
                                    showSidebar.toggle() // toggle sidebar visibility
                                }
                            }
                        )
                        .frame(maxWidth: .infinity, alignment: .top)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        } else {
                            // Chat List
                            List(chats) { chat in
                                NavigationLink(
                                    destination: ChatDetailView(chat: chat),
                                    label: {
                                        HStack(spacing: 15) {
                                            if let profilePicture = chat.profilePicture {
                                                Image(profilePicture)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                            } else {
                                                Circle()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(.gray)
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
                            .background(Color.white)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .onAppear {
                fetchChats()
            }
        }
    }
    
    struct ChatListView_Previews: PreviewProvider {
        static var previews: some View {
            ChatListView()
        }
    }
}
