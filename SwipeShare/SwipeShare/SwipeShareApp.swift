//
//  SwipeShareApp.swift
//  SwipeShare
//
//  Created by Monique Johnson on 11/10/24.
//

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


// MARK: Probably remove this and use the MainHomeView instead
@main
struct SwipeShareApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isAuthenticated = false
    @State private var isLoading = true
    @State private var isGiver = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isLoading {
                    loadingScreen()
                } else {
                    if isAuthenticated && isGiver{
                        GiverHomeView()
                    } else if isAuthenticated && !isGiver{
                        //ReceiverHomeView(isSwipeGiverChecked: $isSwipeGiverChecked)
                    }
                    else {
                        StartUpView(isAuthenticated: $isAuthenticated)
                    }
                }
            }
            
            .onAppear {
                if AppDelegate.isFirebaseConfigured {
                    self.isLoading = false
                }
            }
        }
    }
}
