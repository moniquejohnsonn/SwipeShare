import Foundation
import SwiftUI
import CoreLocation
import FirebaseFirestore

struct MealSwipeRequestView: View {
    @State private var navigateToMapView = false
    @State private var showPopup = false // State to control popup visibility
    @State private var confirmationTimer: Timer? = nil // Timer for the delay
    @State private var selectedDiningHall: DiningHall? = nil
   // @Binding var selectedDiningHall: DiningHall?
    
    var giver: UserProfile
    var diningHall: DiningHall

    var body: some View {
        ZStack {
            
            ScrollView {
                VStack(spacing: 20) {
                    // Simplified Navigation Header
                    
                    HStack {
                        Button(action: {
                            navigateToMapView = true
                            
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .font(.title)
                                Text("Back")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 70)
                    .padding(.bottom, 10)
                    .background(Constants.LightPurple)

                    // Profile Section with Consistent Alignment
                    HStack {
                        Spacer().frame(width: 7) // Adjust spacing to align with other elements
                        Image(uiImage: giver.profilePicture ?? UIImage()) // Use giver's profile picture
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Constants.Turquoise, lineWidth: 4))
                            .shadow(radius: 10)

                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(giver.name) // Display giver's name
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.DarkPurple)
                            
                            Text(giver.year) // Display giver's year
                                .foregroundColor(Constants.DarkPurple)
                                .font(.subheadline)
                        }
                        Spacer() // Add spacer to ensure alignment is consistent
                    }
                    .padding(.horizontal)

                    // Give Rate and Meals Given Section with Consistent Alignment
                    VStack(alignment: .leading, spacing: 12) {
                        // Give Rate
                        HStack {
                            Spacer().frame(width: 7) // Align with the profile section
                            Text("Give Rate:")
                                .font(.headline)
                                .foregroundColor(Constants.DarkPurple)
                            // TODO: add give rate to user profile??
                            /*
                            ForEach(0..<5) { index in
                                if index < giver.giveRate { // Use giver's give rate
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Constants.DarkPurple)
                                } else {
                                    Image(systemName: "star")
                                        .foregroundColor(Constants.LightPurple)
                                }
                            }
                            */
                            Spacer()
                        }
                        .padding(.top, 1)

                        // Meals Given
                        HStack {
                            Spacer().frame(width: 7) // Align with the profile section
                            Text("Meals Given:")
                                .font(.headline)
                                .foregroundColor(Constants.DarkPurple)
                            Text("\(giver.mealCount)") // Use giver's meals given count
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.DarkPurple)
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    .padding()

                    // Availability Section with Proper Alignment
                    HStack {
                        Spacer().frame(width: 20) // Align with the rest of the content
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(Constants.Turquoise)
                        Text("Currently available to give swipes in ")
                            .font(.body)
                            .foregroundColor(Constants.DarkPurple) +
                        Text(diningHall.name)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.DarkPurple)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)

                    Spacer()
                    
                    // Expanded Confirmation Box
                    VStack(spacing: 66) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Constants.Turquoise)
                            .font(.largeTitle)
                        
                        Text("Confirm sending meal swipe request to \(giver.name)?") // Use giver's name
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Turquoise)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Your request is for ")
                                .font(.body)
                                .foregroundColor(Constants.DarkPurple) +
                            Text(diningHall.name)
                           // Text("Hewitt Dining Hall")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.DarkPurple)
                        }

                        HStack(spacing: 40) {
                            Button(action: {
                                // Cancel action
                            }) {
                                Text("Cancel")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(Constants.DarkPurple)
                                    .cornerRadius(9)
                            }
                            
                            Button(action: {
                                // Confirm action
                                confirmationTimer?.invalidate()
                                confirmationTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                                    showPopup = true
                                }
                            }) {
                                Text("Confirm")
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                    .background(Constants.DarkPurple)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding(.horizontal, 0)
                    .padding(.bottom, 0)
                    .ignoresSafeArea(edges: .bottom)
                }
                .padding(.bottom, 20)
                .navigationDestination(isPresented: $navigateToMapView) {
                    ReceiverHomeView2(selectedDiningHall: $selectedDiningHall)
                }
            }
            .background(Constants.LightPurple)
            .ignoresSafeArea(edges: .top)

            // Popup Overlay
            if showPopup {
                VStack {
                    Text("Did you receive your meal swipe from \(giver.name)?") // Use giver's name
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Turquoise)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            // Handle "Yes" action
                            showPopup = false
                            confirmationTimer?.invalidate()
                        }) {
                            Text("Yes")
                                .padding()
                                .frame(maxWidth: 100)
                                .background(Constants.Turquoise)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Handle "No" action
                            showPopup = false
                            confirmationTimer?.invalidate()
                        }) {
                            Text("No")
                                .padding()
                                .frame(maxWidth: 100)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: 300)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 2)
                .transition(.scale)
            }
        }
    }
}

// TODO: remove mock giver and do actual giver that was clicked on
struct MealSwipeRequestView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock Giver object for the preview
        let mockGiver = UserProfile(
            id: UUID().uuidString,
            name: "Tom",
            profilePicture: UIImage(contentsOfFile: "drake2"),
            email: "tom@gmail.com",
            campus: "Columbia University in the City of New York",
            year: "Senior in the School of General Studies",
            major: "Neuroscience",
            numSwipes: 19,
            mealFrequency: "weekly",
            mealCount: 4,
            isGiver: true,
            location: GeoPoint(latitude: 40.8059, longitude: -73.9625)
        )
        let mockDiningHall = DiningHall(
            name: "Hewitt Dining",
            coordinates: [
                CLLocationCoordinate2D(latitude: 40.80847, longitude: -73.9648422), // bottom left
                CLLocationCoordinate2D(latitude: 40.80836, longitude: -73.96457), //bottom right
                CLLocationCoordinate2D(latitude: 40.80896, longitude: -73.964135), //top right
                CLLocationCoordinate2D(latitude: 40.8090612, longitude: -73.9643846) // top left
            
            ]
        )
        
        // Pass the mock Giver to the MealSwipeRequestView
        MealSwipeRequestView(giver: mockGiver, diningHall: mockDiningHall
        )
    }
}
