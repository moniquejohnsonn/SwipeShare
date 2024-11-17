import SwiftUI

struct MenuView: View {
    @ObservedObject var userProfileManager = UserProfileManager()
    @Binding var isSidebarVisible: Bool
    @State private var isVisible = false
    
    var body: some View {
        // z stack for placing over other views
        ZStack(alignment: .leading) {
            // Background color to dim the main content
            if isSidebarVisible {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isSidebarVisible = false
                        }
                    }
            }
            
            HStack(spacing: 0) {
                // stack of menu items
                VStack(alignment: .leading, spacing: 30) {
                    // close buttons
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isSidebarVisible = false
                            }
                        }) {
                            
                            Text("<      Close")
                                .font(.custom("BalooBhaina2-Regular", size: 20))
                                .foregroundColor(Color("secondaryPurple"))
                        }
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 15)
                    
                    HStack {
                        Spacer()
                        Image("LogoIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50)
                        Spacer()
                    }
                    Divider()
                        .frame(height: 1)
                        .background(Color("secondaryPurple"))
                        .opacity(0.5)
                    
                    // menu items
                    NavigationLink(destination: getHomeView(userProfileManager: userProfileManager)) {
                        MenuItem(icon: "house.fill", title: "Home")
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color("secondaryPurple"))
                        .opacity(0.5)
                    
                    // TODO: Update navigation with chat view
                    NavigationLink(destination: ChatListView()) {
                        MenuItem(icon: "bubble.left.and.bubble.right.fill", title: "Chats")
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color("secondaryPurple"))
                        .opacity(0.5)
                    
                    NavigationLink(destination: SettingsView()) {
                        MenuItem(icon: "gearshape.fill", title: "Settings")
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color("secondaryPurple"))
                        .opacity(0.5)
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("My School:")
                            .font(.custom("BalooBhaina2-Bold", size: 25))
                            .foregroundColor(.white)
                        
                        Text("Columbia University")
                            .font(.custom("BalooBhaina2-Regular", size: 25))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(-10)
                        HStack{
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                Image("columbiaLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: 200)
                .background(Color("primaryPurple"))
                .edgesIgnoringSafeArea(.all)
                .offset(x: isSidebarVisible ? 0 : -350)
                .animation(.easeInOut, value: isSidebarVisible)
                
                Spacer()
            }
        }
    }
}


struct MenuItem: View {
    var icon: String
    var title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 30)
            Text(title)
                .font(.custom("BalooBhaina2-Regular", size: 25))
                .foregroundColor(.white)
        }
        .padding(.vertical, 1)
        .padding(.horizontal)
    }
}

// Function to return either Giver or Receiver home view
private func getHomeView(userProfileManager: UserProfileManager) -> some View {
    if let currentUserProfile = userProfileManager.currentUserProfile {
        if currentUserProfile.isGiver {
            return AnyView(GiverHomeView().environmentObject(userProfileManager))
        } else {
            return AnyView(ReceiverHomeView1().environmentObject(userProfileManager))
        }
    }
    return AnyView(EmptyView())
}


struct Menu_Preview: PreviewProvider {
    static var previews: some View {
        MenuPreviewWrapper()
    }
}

// A wrapper view that uses @State for the preview
struct MenuPreviewWrapper: View {
    @State private var isSidebarVisible = true
    
    var body: some View {
        MenuView(isSidebarVisible: $isSidebarVisible)
    }
}

