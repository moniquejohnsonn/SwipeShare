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
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userProfileManager = UserProfileManager()
    @StateObject private var locationManager = LocationManager()
    @State private var isLoading = false
    
    init() {
        // Link dependencies after objects are initialized
        locationManager.userProfileManager = userProfileManager
        userProfileManager.locationManager = locationManager
    }

    var body: some Scene {
        WindowGroup {
            NoBackButtonNavigationStack { // Use the custom wrapper
                if isLoading {
                    loadingScreen()
                } else if !userProfileManager.isLoggedIn || userProfileManager.currentUserProfile == nil {
                    StartUpView()
                        .environmentObject(userProfileManager)
                        .environmentObject(locationManager)
                } else {
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
                    }
                }
            }
            .environmentObject(userProfileManager)
        }
    }
}

