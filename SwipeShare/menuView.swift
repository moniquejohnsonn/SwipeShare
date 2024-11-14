import SwiftUI

struct MenuView: View {
    @Binding var isSidebarVisible: Bool
    
    var body: some View {
        // z stack for placing over other views
        ZStack(alignment: .leading) {
            Color("primaryPurple")
                .edgesIgnoringSafeArea(.all) // extends background color to whole screen
            
            // stack of menu items
            VStack(alignment: .leading, spacing: 30) {
                // close buttons
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isSidebarVisible.toggle()
                        }
                    }) {
                        Text("<      Close")
                            .font(.custom("BalooBhaina2-Regular", size: 20))
                            .foregroundColor(Color("secondaryPurple"))
                    }
                }
                .padding(.top, 40)
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
                MenuItem(icon: "house.fill", title: "Home")
                Divider()
                        .frame(height: 1)
                        .background(Color("secondaryPurple"))
                        .opacity(0.5)
                MenuItem(icon: "bubble.left.and.bubble.right.fill", title: "Chats")
                Divider()
                        .frame(height: 1)
                        .background(Color("secondaryPurple"))
                        .opacity(0.5)
                MenuItem(icon: "gearshape.fill", title: "Settings")
                Divider()
                        .frame(height: 1)
                        .background(Color("secondaryPurple"))
                        .opacity(0.5)
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("My School:")
                        .font(.custom("BalooBhaina2-Bold", size: 25))
                        .foregroundColor(.white)
                    
                    Text("Columbia University")
                        .font(.custom("BalooBhaina2-Regular", size: 25))
                        .foregroundColor(.white)
                    HStack{
                        Spacer()
                        ZStack {
                            // Background white circle
                            Circle()
                                .fill(Color.white) // Background color for better contrast
                                .frame(width: 70, height: 70) // Slightly larger than the image for padding
                            
                            // Logo image on top of the circle
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
            }
        }
        .frame(maxWidth: 200)
        .offset(x: isSidebarVisible ? 0 : -350)
        .animation(.easeInOut, value: isSidebarVisible)
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


struct Menu_Preview: PreviewProvider {
    static var previews: some View {
        MenuView(isSidebarVisible: .constant(true))
    }
}
