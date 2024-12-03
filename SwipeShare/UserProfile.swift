import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

struct UserProfile: Identifiable {
    var id: String
    var name: String
    var profilePictureURL: String?
    var profilePicture: UIImage?
    var email: String
    var campus: String
    var year: String
    var major: String
    var numSwipes: Int
    var mealFrequency: String
    var mealCount: Int
    var isGiver: Bool
    var location: GeoPoint?
    var diningHall: String?
}

// UserProfileManager class
class UserProfileManager: ObservableObject {
    @Published var currentUserProfile: UserProfile? = nil
    @Published var isLoggedIn: Bool = true
    @Published var isLoading: Bool = true
    @Published var loginError: String? = nil
    
    // Lazy initialization for Firestore
    private lazy var db: Firestore = {
        guard AppDelegate.isFirebaseConfigured else {
            fatalError("Firebase is not configured. Call FirebaseApp.configure() before accessing Firestore.")
        }
        return Firestore.firestore()
    }()
    
    weak var locationManager: LocationManager?
    
    init() {
        // Optionally fetch profile on initialization if the user is already logged in
        if Auth.auth().currentUser != nil {
            fetchUserProfile()
        }
    }
    
    
    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error)
                return
            }
            
            self?.fetchUserProfile {
                completion(nil)
            }
        }
    }
    
    func fetchProfilePicture(for userProfile: UserProfile, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: userProfile.profilePictureURL ?? "") else {
            print("Invalid profile picture URL: \(String(describing: userProfile.profilePictureURL))")
            DispatchQueue.main.async {
                completion(UIImage(named: "profilePicHolder"))
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching profile picture: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(UIImage(named: "profilePicHolder"))
                }
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("Failed to decode image data")
                DispatchQueue.main.async {
                    completion(UIImage(named: "profilePicHolder"))
                }
            }
        }
        task.resume()
    }
    
    
    func fetchUserProfile(completion: @escaping () -> Void = {}) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.isLoading = false
            completion()
            return
        }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            self.isLoading = false
            if let data = snapshot?.data() {
                var userProfile = UserProfile(
                    id: uid,
                    name: data["name"] as? String ?? "Unknown",
                    profilePictureURL: data["profilePictureURL"] as? String ?? "",
                    email: data["email"] as? String ?? "Unknown",
                    campus: data["campus"] as? String ?? "Unknown",
                    year: data["year"] as? String ?? "Unknown",
                    major: data["major"] as? String ?? "Unknown",
                    numSwipes: data["numSwipes"] as? Int ?? 0,
                    mealFrequency: data["mealFrequency"] as? String ?? "Unknown",
                    mealCount: data["mealCount"] as? Int ?? 0,
                    isGiver: data["isGiver"] as? Bool ?? false,
                    location: data["location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0),
                    diningHall: data["diningHall"] as? String ?? "None"
                )
                
                self.fetchProfilePicture(for: userProfile) { image in
                    userProfile.profilePicture = image
                    DispatchQueue.main.async {
                        self.currentUserProfile = userProfile
                        completion()
                    }
                }
            } else {
                print("Error fetching user profile: \(error?.localizedDescription ?? "Unknown error")")
                completion()
            }
        }
    }
    
    func fetchUserDetails(userID: String, completion: @escaping (UserProfile?) -> Void) {
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                let userProfile = UserProfile(
                    id: userID,
                    name: data["name"] as? String ?? "Unknown",
                    profilePictureURL: data["profilePictureUrl"] as? String ?? "",
                    email: data["email"] as? String ?? "Unknown",
                    campus: data["campus"] as? String ?? "Unknown",
                    year: data["year"] as? String ?? "Unknown",
                    major: data["major"] as? String ?? "Unknown",
                    numSwipes: data["numSwipes"] as? Int ?? 0,
                    mealFrequency: data["mealFrequency"] as? String ?? "Unknown",
                    mealCount: data["mealCount"] as? Int ?? 0,
                    isGiver: data["isGiver"] as? Bool ?? false,
                    location: data["location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0),
                    diningHall: data["diningHall"] as? String ?? "None"
                )
                completion(userProfile)
            } else {
                print("Error fetching user details: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
    
    func saveUserProfile(profile: UserProfile, completion: @escaping (Error?) -> Void) {
        var data: [String: Any] = [
            "name": profile.name,
            "profilePictureURL": profile.profilePictureURL ?? "",
            "email": profile.email,
            "campus": profile.campus,
            "year": profile.year,
            "major": profile.major,
            "numSwipes": profile.numSwipes,
            "mealFrequency": profile.mealFrequency,
            "mealCount": profile.mealCount,
            "isGiver": profile.isGiver
        ]
        
        // add location only if it's not nulll
        if let location = profile.location {
            data["location"] = location
        }
        
        db.collection("users").document(profile.id).setData(data) { error in
            completion(error)
        }
    }
    
    func getPendingRequests(for userId: String, completion: @escaping ([UserProfile]) -> Void) {
        print("Fetching pending requests for userId: \(userId)")
        
        var pendingReceivers: [UserProfile] = []
        
        guard let userId = currentUserProfile?.id else {
            print("User ID is nil. Exiting getPendingRequests.")
            return
        }
        
        print("Fetching chats for user ID: \(userId)")
        
        db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching chats: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let dispatchGroup = DispatchGroup() // To handle async calls for fetching user details
                
                for document in documents {
                    let data = document.data()
                    let participants = data["participants"] as? [String] ?? []
                    
                    // Determine the other participant (receiver)
                    let receiverId = participants.first { $0 != Auth.auth().currentUser?.uid }
                    
                    // Fetch the messages to check if there's an "initial" message
                    if let receiverId = receiverId {
                        dispatchGroup.enter()
                        self.db.collection("chats")
                            .document(document.documentID)
                            .collection("messages")
                            .whereField("type", isEqualTo: "initial")
                            .getDocuments { messagesSnapshot, messageError in
                                if let messageError = messageError {
                                    print("Error fetching messages: \(messageError.localizedDescription)")
                                } else {
                                    // If an "initial" message exists, proceed
                                    if let messages = messagesSnapshot?.documents, !messages.isEmpty {
                                        let initialMessageSender = messages.first?["senderID"] as? String
                                        
                                        // Check if the receiverId matches the senderId of the initial message
                                        if initialMessageSender == receiverId {
                                            // Fetch the receiver's profile
                                            self.db.collection("users").document(receiverId).getDocument { userSnapshot, userError in
                                                if let userError = userError {
                                                    print("Error fetching user details: \(userError.localizedDescription)")
                                                } else if let userData = userSnapshot?.data() {
                                                    let profile = UserProfile(
                                                        id: receiverId,
                                                        name: userData["name"] as? String ?? "Unknown",
                                                        profilePictureURL: userData["profilePictureURL"] as? String,
                                                        email: userData["email"] as? String ?? "Unknown",
                                                        campus: userData["campus"] as? String ?? "Unknown",
                                                        year: userData["year"] as? String ?? "Unknown",
                                                        major: userData["major"] as? String ?? "Unknown",
                                                        numSwipes: userData["numSwipes"] as? Int ?? 0,
                                                        mealFrequency: userData["mealFrequency"] as? String ?? "Unknown",
                                                        mealCount: userData["mealCount"] as? Int ?? 0,
                                                        isGiver: userData["isGiver"] as? Bool ?? false,
                                                        location: userData["location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0),
                                                        diningHall: userData["diningHall"] as? String ?? "None"
                                                    )
                                                    
                                                    // Only add the profile if it isn't already in the list
                                                    if !pendingReceivers.contains(where: { $0.id == profile.id }) {
                                                        print("Adding profile: \(profile.name) to pending requests.")
                                                        pendingReceivers.append(profile)
                                                    }
                                                }
                                                dispatchGroup.leave()
                                            }
                                        } else {
                                            dispatchGroup.leave()
                                        }
                                    } else {
                                        // No "initial" message found, so we skip
                                        dispatchGroup.leave()
                                    }
                                }
                            }
                    }
                }
                
                // Update the UI after all user details are fetched
                dispatchGroup.notify(queue: .main) {
                    print("Fetched pending requests: \(pendingReceivers)")
                    completion(pendingReceivers)
                }
            }
    }
    
    
    // Log out the user and reset the profile
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUserProfile = nil
            self.isLoggedIn = false
            locationManager?.stopMonitoringGeofences() // Stop geofencing
        } catch let error {
            print("Error signing out: \(error)")
        }
    }
    
    // update user location when they move in and out of dining hall geofencing
    func updateUserLocation(uid: String, location: GeoPoint, diningHall: String, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(uid).updateData(["location": location, "diningHall": diningHall]) { error in
            if let error = error {
                print("Error updating user location: \(error.localizedDescription)")
                completion(error)
            } else {
                print("User location updated successfully.")
                completion(nil)
            }
        }
    }
    
    // fetch either receivers or givers in a dining hall
    private func fetchUsersInDiningHall(role: String, diningHallName: String, completion: @escaping ([UserProfile]) -> Void) {
        db.collection("users")
            .whereField("diningHall", isEqualTo: diningHallName)
            .whereField("isGiver", isEqualTo: role == "giver")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching \(role)s in \(diningHallName): \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let users = snapshot?.documents.compactMap { doc -> UserProfile? in
                    let data = doc.data()
                    guard let id = doc.documentID as String?,
                          let name = data["name"] as? String,
                          let isGiver = data["isGiver"] as? Bool,
                          let location = data["location"] as? GeoPoint else { return nil }
                    
                    return UserProfile(
                        id: id,
                        name: name,
                        profilePictureURL: data["profilePictureURL"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        campus: data["campus"] as? String ?? "",
                        year: data["year"] as? String ?? "",
                        major: data["major"] as? String ?? "",
                        numSwipes: data["numSwipes"] as? Int ?? 0,
                        mealFrequency: data["mealFrequency"] as? String ?? "",
                        mealCount: data["mealCount"] as? Int ?? 0,
                        isGiver: isGiver,
                        location: location,
                        diningHall: data["diningHall"] as? String
                    )
                } ?? []
                
                completion(users)
            }
    }
    
    // get users for a dining hall and specify if you want to include mock users or not
    func getUsersForDiningHall(role: String, diningHall: DiningHall, includeMock: Bool = true, completion: @escaping ([UserProfile]) -> Void) {
        fetchUsersInDiningHall(role: role, diningHallName: diningHall.name) { firebaseUsers in
            var users: [UserProfile] = []
            
            // Use Firebase users if the query succeeds
            users = firebaseUsers
            
            if includeMock {
                // Filter mock users based on dining hall
                if role == "giver" {
                    let filteredMockGivers = mockGivers.filter { $0.diningHall == diningHall.name }
                    users.append(contentsOf: filteredMockGivers)
                } else if role == "receiver" {
                    let filteredMockReceivers = mockReceivers.filter { $0.diningHall == diningHall.name }
                    users.append(contentsOf: filteredMockReceivers)
                }
            }
            
            print("Success, users: \(users)")
            completion(users)
        }
    }
    
    func getRecentFulfilledSwipes(for giverId: String, completion: @escaping ([UserProfile]) -> Void) {
        let fulfilledSwipesRef = db.collection("fulfilledSwipes")
        fulfilledSwipesRef
            .whereField("giverId", isEqualTo: giverId) // Filter by giverId
            .order(by: "timestamp", descending: true) // Sort by most recent requests
            .limit(to: 5) // Limit to 5
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching recent swipes: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                var recentReceivers: [UserProfile] = []
                
                let dispatchGroup = DispatchGroup() // wait for async tasks
                for document in documents {
                    let data = document.data()
                    if let receiverId = data["receiverId"] as? String {
                        dispatchGroup.enter()
                        self.fetchUserDetails(userID: receiverId) { userProfile in
                            if let userProfile = userProfile {
                                recentReceivers.append(userProfile)
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(recentReceivers)
                }
            }
    }
    
    
}
