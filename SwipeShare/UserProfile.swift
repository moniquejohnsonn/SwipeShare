import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

struct UserProfile: Identifiable {
    var id: String
    var name: String
    var profilePictureURL: String
    var profilePicture: UIImage?
    var email: String
    var campus: String
    var year: String
    var major: String
    var numSwipes: Int
    var mealFrequency: String
    var mealCount: Int
    var isGiver: Bool
}

// UserProfileManager class
class UserProfileManager: ObservableObject {
    @Published var currentUserProfile: UserProfile? = nil
    @Published var isLoggedIn: Bool = true
    @Published var isLoading: Bool = true
    @Published var loginError: String? = nil
    
    private let db = Firestore.firestore()
    
    init() {
        // Optionally fetch profile on initialization if user is already logged in
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
        guard let url = URL(string: userProfile.profilePictureURL) else {
            print("Invalid profile picture URL: \(userProfile.profilePictureURL)")
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
                    isGiver: data["isGiver"] as? Bool ?? false
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
                    isGiver: data["isGiver"] as? Bool ?? false
                )
                completion(userProfile)
            } else {
                print("Error fetching user details: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
    
    func saveUserProfile(profile: UserProfile, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(profile.id).setData([
            "name": profile.name,
            "profilePictureURL": profile.profilePictureURL,
            "email": profile.email,
            "campus": profile.campus,
            "year": profile.year,
            "major": profile.major,
            "numSwipes": profile.numSwipes,
            "mealFrequency": profile.mealFrequency,
            "mealCount": profile.mealCount,
            "isGiver": profile.isGiver
        ]) { error in
            completion(error)
        }
    }
    
    // Log out the user and reset the profile
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUserProfile = nil
            self.isLoggedIn = false
        } catch let error {
            print("Error signing out: \(error)")
        }
    }
}
