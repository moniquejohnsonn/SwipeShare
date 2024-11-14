//
//  userData.swift
//  SwipeShare
//
// *** TEMP FILE FOR MANAGING USER DATA WHILE FIREBASE
// *** USER MANAGEMENT GETS SET UP
//
//  Created by Rosa Figueroa on 11/13/24.
//

import Foundation

class UserData {
    
    private static let userRoleKey = "userRole"
    
    /// saves the user type ("giver" or "receiver") to UserDefaults
    static func saveUserRole(_ userType: String) {
        UserDefaults.standard.set(userType, forKey: userRoleKey)
        UserDefaults.standard.synchronize()
    }
    
    /// retrieves the user type from UserDefaults
    static func getUserRole() -> String? {
        return UserDefaults.standard.string(forKey: userRoleKey)
    }
    
    /// Clears the saved user type from UserDefaults
    static func clearUserRole() {
        UserDefaults.standard.removeObject(forKey: userRoleKey)
        UserDefaults.standard.synchronize()
    }
}

