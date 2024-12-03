import SwiftUI
import CoreLocation




// MARK: used to conform to the Equatable protocol to compare two CLLocationCoordinate2D instances
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct GiverHomeView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var showSidebar = false
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State private var receiversInArea: [UserProfile] = []
    @State private var recentFulfilledRequests: [UserProfile] = []
    @State private var pendingRequests: [UserProfile] = []

    // mocked data
    // TODO: replace mocked data with actual calls to firebase to get total requests filled by giver and total receivers helped by giver
    let totalRequestsFulfilled = 5
    let totalReceiversHelped = 3

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
                
                // Giver stats section
                VStack(alignment: .leading, spacing: 12) {
                    // Giver requests fulfilled count cards
                    HStack {
                        StatCardView(title: "Requests Fulfilled", value: "\(totalRequestsFulfilled)")
                        StatCardView(title: "Receivers Helped", value: "\(totalReceiversHelped)")
                    }
                    .padding(.top, 10)

                    // giver location card
                    // shows either dining hall theyre in or "not in dining hall"
                    // if in dining hall, show # of receivers in dining hall
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color("primaryGreen"))

                        Text("Your Location:")
                            .font(.headline)

                        if let diningHall = locationManager.currentDiningHall {
                            HStack{
                                Image(systemName: "fork.knife")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color("primaryGreen"))
                                Text(diningHall.name)
                                    .font(.headline)
                                    .foregroundColor(Color("primaryGreen"))
                            }
                            Text("\(receiversInArea.count) receivers in \(diningHall.name)")
                                .font(.subheadline)
                                .foregroundColor(Color("primaryPurple"))
                        } else {
                            HStack {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color("secondaryPurple"))
                                    .padding(.leading, 10)
                                            
                                Text("Not currently in a dining hall")
                                    .font(.headline)
                                    .foregroundColor(Color("primaryPurple"))
                                    .padding(.leading, 10)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding()

                // recent requests section
                Text("Recent Swipe Requests")
                    .font(.custom("BalooBhaina2-Bold", size: 30))
                    .foregroundColor(Color("primaryPurple"))
                    .padding(.horizontal, 20)
                    .frame(alignment: .leading)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(recentFulfilledRequests) { receiver in
                            ReceiverRow(receiver: receiver)
                                .padding(.horizontal)
                        }

                        if recentFulfilledRequests.isEmpty {
                            Text("No fulfilled requests yet.")
                                .foregroundColor(Color("secondaryPurple"))
                                .font(.custom("BalooBhaina2-Regular", size: 18))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        PendingRequestsView(pendingRequests: $pendingRequests)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
            }
            .onAppear {
                fetchPendingRequests()
                
                locationManager.updateCurrentDiningHall()
                if let diningHall = locationManager.currentDiningHall {
                    print("Currently in dining hall: \(diningHall.name)")
                    fetchReceiversForDiningHall(hall: diningHall)
                } else {
                    print("not currently in dining hall")
                }
            }
            .edgesIgnoringSafeArea(.top)

            // monitors changes to giverLocation
            .onChange(of: locationManager.currentDiningHall, initial: false) { newDiningHall, _ in
                if let hall = newDiningHall {
                        // Fetch receivers for the current dining hall
                        print("Entered dining hall: \(hall.name)")
                        fetchReceiversForDiningHall(hall: hall)
                    } else {
                        self.receiversInArea = []
                    }
            }
            // Sidebar Content
            MenuView(isSidebarVisible: $showSidebar)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.move(edge: .leading))
                .padding(.leading, 0)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    struct PendingRequestRow: View {
        let receiver: UserProfile
        let onAccept: () -> Void
        let onDecline: () -> Void

        var body: some View {
            HStack {
                if let profilePicture = receiver.profilePictureURL {
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
                }
                
                Text(receiver.name)
                    .font(.custom("BalooBhaina2-Bold", size: 20))
                    .foregroundColor(Color("primaryPurple"))

                Spacer()

                HStack(spacing: 16) {
                    Button(action: onAccept) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.green)
                            .font(.title)
                    }
                    Button(action: onDecline) {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(Color.red)
                            .font(.title)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
        }
    }
    
    struct PendingRequestsView: View {
        @Binding var pendingRequests: [UserProfile]

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Pending Requests")
                    .font(.custom("BalooBhaina2-Bold", size: 30))
                    .foregroundColor(Color("primaryPurple"))
                    .padding(.horizontal, 20)
                    .frame(alignment: .leading)

                ForEach(pendingRequests) { receiver in
                    PendingRequestRow(
                        receiver: receiver,
                        onAccept: {
                            print("Accepted request for \(receiver.name)")
                            // Add accept logic
                        },
                        onDecline: {
                            print("Declined request for \(receiver.name)")
                            // Add decline logic
                        }
                    )
                    .padding(.horizontal)
                }

                if pendingRequests.isEmpty {
                    Text("No pending requests.")
                        .foregroundColor(Color("secondaryPurple"))
                        .font(.custom("BalooBhaina2-Regular", size: 18))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    private func fetchPendingRequests() {
        guard let userId = userProfileManager.currentUserProfile?.id else {
            print("User ID not found")
            return
        }
        userProfileManager.getPendingRequests(for: userId) { fetchedRequests in
            DispatchQueue.main.async {
                print("Fetched pending requests: \(fetchedRequests)")
                self.pendingRequests = fetchedRequests
            }
        }
    }
    
    private func fetchReceiversForDiningHall(hall: DiningHall) {
        userProfileManager.getUsersForDiningHall(role: "receiver", diningHall: hall, includeMock: true) { fetchedReceivers in
            DispatchQueue.main.async {
                self.receiversInArea = fetchedReceivers
            }
        }
    }
    
    private func fetchRecentFulfilledRequests() {
        guard let currentUser = userProfileManager.currentUserProfile else { return }
        userProfileManager.getRecentFulfilledSwipes(for: currentUser.id) { recentReceivers in
            self.recentFulfilledRequests = recentReceivers
        }
    }
}

// MARK: - Stat Card View
struct StatCardView: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.custom("BalooBhaina2-Bold", size: 30))
                .foregroundColor(Color("primaryPurple"))
            Text(title)
                .font(.custom("BalooBhaina2-Regular", size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

// MARK: - ReceiverRow
struct ReceiverRow: View {
    let receiver: UserProfile

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(uiImage: receiver.profilePicture ?? UIImage(named: "profilePlaceholder")!)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(receiver.name)
                    .font(.custom("BalooBhaina2-Bold", size: 22))
                    .foregroundColor(Color("primaryPurple"))
                
                Text("Recently fulfilled swipe")
                    .font(.custom("BalooBhaina2-Regular", size: 16))
                    .foregroundColor(Color("primaryPurple"))
            }
            
            Spacer()

            VStack {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("primaryGreen"))
            }
        }
        .padding()
        .background(Color("secondaryPurple").opacity(0.1))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}


#Preview {

}


