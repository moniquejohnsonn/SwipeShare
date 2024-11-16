import SwiftUI

struct ChatDetailView: View {
    @Environment(\.presentationMode) var presentationMode // For back navigation
    @State private var newMessage: String = "" // For typing new messages
    
    // Example chat data
    let chat: Chat
    @State private var messages: [Message] = [
        Message(id: "1", content: "Hello!", isFromCurrentUser: true),
        Message(id: "2", content: "Hi there!", isFromCurrentUser: false),
        Message(id: "3", content: "How are you doing?", isFromCurrentUser: true),
        Message(id: "4", content: "I'm good, thanks! You?", isFromCurrentUser: false)
    ]
    
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
                    Image(chat.profilePicture)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
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
            }
            .padding()
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // Send a new message
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        messages.append(Message(id: UUID().uuidString, content: newMessage, isFromCurrentUser: true))
        newMessage = ""
    }
}

// Message Model
struct Message: Identifiable {
    let id: String
    let content: String
    let isFromCurrentUser: Bool
}

#Preview {
    ChatDetailView(chat: Chat(
        id: "1",
        name: "John Doe",
        profilePicture: "profile1",
        lastMessage: "Hey, how are you?",
        timestamp: "2:30 PM"
    ))
}
