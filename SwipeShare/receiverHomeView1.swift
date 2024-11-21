import SwiftUI
import MapKit

struct ReceiverHomeView1: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var showSidebar = false
    @State private var selectedDiningHall: DiningHall? = nil // state for selected dining hall

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
                
                Text("Swipe Givers")
                    .font(.custom("BalooBhaina2-Bold", size: 30))
                    .foregroundColor(Color("primaryPurple"))
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .frame(alignment: .leading)
                
                ScrollView {
                    ForEach(diningHalls, id: \.name) { hall in
                        let hallGivers = getGiversForDiningHall(givers: givers, diningHall: hall)
                        
                        // set `selectedDiningHall` when this row is tapped
                        NavigationLink(
                            destination: ReceiverHomeView2(selectedDiningHall: .constant(hall))
                        ) {
                            DiningHallRow(diningHall: hall, giverCount: hallGivers.count)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .edgesIgnoringSafeArea(.top)

            // Sidebar content
            MenuView(isSidebarVisible: $showSidebar)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.move(edge: .leading))
                .padding(.leading, 0)
        }
        .navigationBarBackButtonHidden(true)
        
    }
       
}

struct DiningHallRow: View {
    let diningHall: DiningHall
    let giverCount: Int

    var body: some View {
        HStack {
            Image("pin")
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.leading, 10) // Fixed position on the left

            VStack(alignment: .leading) {
                Text(diningHall.name)
                    .font(.custom("BalooBhaina2-Bold", size: 20))
                    .foregroundColor(Color("darkestPurple"))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            .padding(.leading, 10) // Adjust padding to provide some space after the pin

            Spacer() // Push the triangle and giver count to the right

            HStack(spacing: 8) { // Increased spacing to 8 for more space between the triangle and number
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(giverCount == 0 ? Color(red: 245/255, green: 168/255, blue: 169/255) : Color("secondaryGreen"))
                    .rotationEffect(Angle(degrees: giverCount == 0 ? 180 : 0)) // Rotate if count is 0
                    .padding(.trailing, -4) // Move triangle slightly left

                Text("\(giverCount)")
                    .font(.custom("BalooBhaina2-Regular", size: 16))
                    .foregroundColor(.black)
                    .padding(.top, 4)
            }
            .padding(.trailing, 8)
          
        }
        .padding()
        .background(Color("secondaryPurple").opacity(0.5))
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding(.vertical, 5)
    }
}

// Preview
struct ReceiverHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiverHomeView1()
    }
}

