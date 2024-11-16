import SwiftUI

struct ChatListView: View {
    @State private var showSidebar = false
    
    // TODO: Use Firebase Database to pull info
    let chats = [
        Chat(id: "1", name: "John Doe", profilePicture: "profile1", lastMessage: "Hey, how are you?", timestamp: "2:30 PM"),
        Chat(id: "2", name: "Jane Smith", profilePicture: "profile2", lastMessage: "See you tomorrow!", timestamp: "1:15 PM"),
        Chat(id: "3", name: "Alice Johnson", profilePicture: "profile3", lastMessage: "Thanks for the help!", timestamp: "11:45 AM")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sidebar
                if showSidebar {
                    MenuView(isSidebarVisible: $showSidebar)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.move(edge: .leading))
                }
                
                // Main Content
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
                    
                    // Chat List
                    List(chats) { chat in
                        HStack(spacing: 15) {
                            Image(chat.profilePicture)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            
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
                    .listStyle(PlainListStyle())
                    .background(Color.white)
                }
                .background(Color("lightBackground"))
                .edgesIgnoringSafeArea(.top)
            }
        }
    }
}

// TODO: Change struct with info we want
struct Chat: Identifiable {
    let id: String
    let name: String
    let profilePicture: String // Name of the image asset
    let lastMessage: String
    let timestamp: String
}

#Preview {
    ChatListView()
}
