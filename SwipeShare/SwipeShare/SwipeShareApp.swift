//
//  SwipeShareApp.swift
//  SwipeShare
//
//  Created by Monique Johnson on 11/10/24.
//

import SwiftUI
import FirebaseCore


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
    @State private var isAuthenticated = false
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if isLoading {
                    loadingScreen()
                } else {
                    if isAuthenticated {
                        mainPage()
                    } else {
                        homeView(isAuthenticated: $isAuthenticated)
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
