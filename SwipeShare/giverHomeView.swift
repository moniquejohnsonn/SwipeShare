import SwiftUI


struct GiverHomeView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var showSidebar = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(
                    title: "Home",
                    showBackButton: false,
                    onHeaderButtonTapped: {
                        withAnimation {
                            showSidebar.toggle() // toggle sidebar visibility
                        }
                    }
                )
                
                Text("Swipe Requests")
                    .font(.custom("BalooBhaina2-Bold", size: 30))
                    .foregroundColor(Color("primaryPurple"))
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .frame(alignment: .leading)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(receivers) { receiver in
                            ReceiverRow(receiver: receiver)
                                .padding(.horizontal)
                        }

                        if receivers.isEmpty {
                            Text("No other receivers")
                                .foregroundColor(Color("secondaryPurple"))
                                .font(.custom("BalooBhaina2-Regular", size: 18))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal)
            }
            .edgesIgnoringSafeArea(.top)

            // sidebar content
            MenuView(isSidebarVisible: $showSidebar)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.move(edge: .leading))
                .padding(.leading, 0)
        
        }
    }
}


struct ReceiverRow: View {
    let receiver: Receiver
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            receiver.profileImage
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(receiver.name)
                    .font(.custom("BalooBhaina2-Bold", size: 22))
                    .foregroundColor(Color("primaryPurple"))
                
                Text(receiver.message)
                    .font(.custom("BalooBhaina2-Regular", size: 16))
                    .foregroundColor(Color("primaryPurple"))
            }
            
            Spacer()

            VStack {
                Text(receiver.date)
                    .font(.custom("BalooBhaina2-Regular", size: 14))
                    .foregroundColor(Color("secondaryGreen"))
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("secondaryGreen"))
            }
        }
        .padding()
        .background(Color("secondaryPurple").opacity(0.1))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct ReceiversView_Previews: PreviewProvider {
    static var previews: some View {
        GiverHomeView()
    }
}
