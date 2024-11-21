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
    @State private var isLoading = false

    var body: some Scene {
        WindowGroup {
            NoBackButtonNavigationStack { // Use the custom wrapper
                if isLoading {
                    loadingScreen()
                } else if !userProfileManager.isLoggedIn || userProfileManager.currentUserProfile == nil {
                    StartUpView()
                        .environmentObject(userProfileManager)
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

