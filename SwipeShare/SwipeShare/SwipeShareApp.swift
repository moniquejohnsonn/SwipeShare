import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    static var isFirebaseConfigured = false
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        AppDelegate.isFirebaseConfigured = true
        
        return true
    }
}

@main
struct SwipeShareApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userProfileManager = UserProfileManager()
    @StateObject private var locationManager = LocationManager()
    @State private var isLoading = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isLoading {
                    loadingScreen()
                } else if !userProfileManager.isLoggedIn || userProfileManager.currentUserProfile == nil {
                    StartUpView()
                        .environmentObject(userProfileManager)
                        .environmentObject(locationManager)
                } else {
                    // Dynamically navigate based on user's role
                    VStack {
                        if let userProfile = userProfileManager.currentUserProfile {
                            if userProfile.isGiver {
                                GiverHomeView()
                                    .environmentObject(userProfileManager)
                            } else {
                                ReceiverHomeView1()
                                    .environmentObject(userProfileManager)
                            }
                        }
                    }
                    .onChange(of: userProfileManager.currentUserProfile?.isGiver) { _ in
                        // Handle any necessary updates when the user's role changes
                        // This ensures the view updates when the role changes
                    }
                }
            }
            .environmentObject(userProfileManager)
        }
    }
}
