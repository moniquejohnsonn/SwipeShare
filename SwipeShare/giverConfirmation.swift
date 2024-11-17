import Foundation
import SwiftUI

struct MealSwipeRequestView: View {
    @State private var navigateToMapView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Simplified Navigation Header
                HStack {
                    Button(action: {
                        navigateToMapView = true;
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
                    Image("drake2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Constants.Turquoise, lineWidth: 4))
                        .shadow(radius: 10)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tom")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.DarkPurple)
                        
                        Text("Senior in the School of General Studies")
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
                        ForEach(0..<5) { index in
                            if index < 4 {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Constants.DarkPurple)
                            } else {
                                Image(systemName: "star")
                                    .foregroundColor(Constants.LightPurple)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 1)

                    // Meals Given
                    HStack {
                        Spacer().frame(width: 7) // Align with the profile section
                        Text("Meals Given:")
                            .font(.headline)
                            .foregroundColor(Constants.DarkPurple)
                        Text("18")
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
                    Text("Hewitt")
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
                    
                    Text("Confirm sending meal swipe request to Tom?")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Turquoise)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Your request is for ")
                            .font(.body)
                            .foregroundColor(Constants.DarkPurple) +
                        Text("Hewitt Dining Hall")
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
                ReceiverHomeView2()
            }
        }
        .background(Constants.LightPurple)
        .ignoresSafeArea(edges: .top)
    }
}

struct MealSwipeRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MealSwipeRequestView()
    }
}

