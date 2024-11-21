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
    @State private var currentDiningHall: DiningHall? = nil
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State private var receiversInArea: [Receiver] = []

    // mocked data
    // TODO: replace mocked data with actual calls to firebase to get total requests filled by giver and total receivers helped by giver
    let totalRequestsFulfilled = 25
    let totalReceiversHelped = 15

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

                        if let diningHall = currentDiningHall {
                            HStack{
                                Image(systemName: "fork.knife")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color("primaryGreen"))
                                Text(diningHall.name)
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            Text("(\(receiversInArea.count) receivers in \(diningHall.name)")
                                .font(.subheadline)
                                .foregroundColor(.green)
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
                    .padding(.top, 10)
                }
                .padding(.horizontal)
            }
            .edgesIgnoringSafeArea(.top)
            // ensures the app begins tracking the user’s location when the view becomes visible
            .onAppear {
                locationManager.startUpdatingLocation()
            }
            // monitors changes to giverLocation
            .onChange(of: locationManager.userLocation, initial: false) { newLocation, _ in
                // get giver coordinates
                guard let userCoordinates = newLocation else { return }
                userLocation = userCoordinates

                // check if the user is inside any dining hall
                currentDiningHall = findDiningHall(for: userCoordinates)

                // find receivers in the area if inside a dining hall
                if let diningHall = currentDiningHall {
                    receiversInArea = getReceiversForDiningHall(receivers: receivers, diningHall: diningHall)
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

    // MARK: - determine dining hall a giver is inside of
    func findDiningHall(for location: CLLocationCoordinate2D) -> DiningHall? {
        for hall in diningHalls {
            if isPointInsidePolygon(point: location, polygon: hall.coordinates) {
                return hall
            }
        }
        return nil
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
                    .foregroundColor(Color("primaryGreen"))
                
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
    NoBackButtonNavigationStack {
        GiverHomeView()
    }
}


