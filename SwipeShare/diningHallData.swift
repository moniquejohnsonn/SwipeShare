//
//  diningHallData.swift
//  SwipeShare
//
//  Created by Rosa Figueroa on 11/13/24.
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore



// Define a DiningHall struct
struct DiningHall: Equatable {
    let name: String
    let coordinates: [CLLocationCoordinate2D]
    
    // Calculate the center coordinate of the dining hall polygon
    var centerCoordinate: CLLocationCoordinate2D {
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let avgLatitude = latitudes.reduce(0, +) / Double(latitudes.count)
        let avgLongitude = longitudes.reduce(0, +) / Double(longitudes.count)
        
        return CLLocationCoordinate2D(latitude: avgLatitude, longitude: avgLongitude)
    }
    
    // Implement Equatable conformance
    static func == (lhs: DiningHall, rhs: DiningHall) -> Bool {
        return lhs.name == rhs.name &&
               lhs.centerCoordinate.latitude == rhs.centerCoordinate.latitude &&
               lhs.centerCoordinate.longitude == rhs.centerCoordinate.longitude
    }
}

// mock givers
let mockGivers: [UserProfile] = [
    UserProfile(id: UUID().uuidString, name: "Alice", profilePictureURL: "", profilePicture: UIImage(named: "alice"), email: "alice@gmail.com", campus: "Columbia University in the City of New York", year: "Sophomore at Barnard College", major: "Psychology", numSwipes: 132, mealFrequency: "semesterly", mealCount: 10, isGiver: true, location: GeoPoint(latitude: 40.8057, longitude: -73.9621), diningHall: "John Jay Dining Hall"),
    UserProfile(id: UUID().uuidString, name: "Joe", profilePictureURL: "", profilePicture: UIImage(named: "joe"), email: "joe@gmail.com", campus: "Columbia University in the City of New York", year: "Freshman at Columbia College", major: "Neuroscience", numSwipes: 19, mealFrequency: "weekly", mealCount: 4, isGiver: true, location: GeoPoint(latitude: 40.8059, longitude: -73.9625), diningHall: "John Jay Dining Hall"),
    UserProfile(id: UUID().uuidString, name: "Bob", profilePictureURL: "", profilePicture: UIImage(named: "bob"), email: "bob@gmail.com", campus: "Columbia University in the City of New York", year: "Senior at Columbia College", major: "Mathematics", numSwipes: 87, mealFrequency: "semesterly", mealCount: 21, isGiver: true, location: GeoPoint(latitude: 40.8068, longitude: -73.9638), diningHall: "Ferris Booth Commons")
] 

// mock receivers
let mockReceivers: [UserProfile] = [
    UserProfile(id: UUID().uuidString, name: "Jon", profilePictureURL: "", profilePicture: UIImage(named: "joe"), email: "jon@gmail.com", campus: "Columbia University in the City of New York", year: "Senior at Columbia Engineering", major: "Computer Science", numSwipes: 0, mealFrequency: "", mealCount: 0, isGiver: false, location: GeoPoint(latitude: 40.8057, longitude: -73.9621), diningHall: "Ferris Booth Commons"),
    UserProfile(id: UUID().uuidString, name: "Lily", profilePictureURL: "", profilePicture: UIImage(named: "alice"), email: "lily@gmail.com", campus: "Columbia University in the City of New York", year: "Junior at the School of General Studies", major: "Human Rights", numSwipes: 0, mealFrequency: "", mealCount: 0, isGiver: false, location: GeoPoint(latitude: 40.8057, longitude: -73.9648422), diningHall: "Hewitt Dining"),
    UserProfile(id: UUID().uuidString, name: "Sam", profilePictureURL: "", profilePicture: UIImage(named: "bob"), email: "sam@gmail.com", campus: "Columbia University in the City of New York", year: "Sophomore at Columbia College", major: "Biology", numSwipes: 0, mealFrequency: "", mealCount: 0, isGiver: false, location: GeoPoint(latitude: 40.8057, longitude: -73.9621), diningHall: "John Jay Dining Hall"),
]


let diningHalls: [DiningHall] = [
    DiningHall(
        name: "John Jay Dining Hall",
        coordinates: [
            CLLocationCoordinate2D(latitude: 40.805623, longitude: -73.9621324),
            CLLocationCoordinate2D(latitude: 40.8059040, longitude: -73.962835),
            CLLocationCoordinate2D(latitude: 40.806099, longitude: -73.9627),
            CLLocationCoordinate2D(latitude: 40.8058169, longitude: -73.961997)
        ]
    ),
    DiningHall(
        name: "Ferris Booth Commons",
        coordinates: [
            CLLocationCoordinate2D(latitude: 40.8071641, longitude: -73.9640370),
            CLLocationCoordinate2D(latitude: 40.8069122, longitude: -73.96345),
            CLLocationCoordinate2D(latitude: 40.80652, longitude: -73.96375),
            CLLocationCoordinate2D(latitude: 40.8067554, longitude: -73.9643234)
        ]
    ),
    DiningHall(
        name: "Grace Dodge Dining Hall",
        coordinates: [
            CLLocationCoordinate2D(latitude: 40.8102, longitude: -73.95989),
            CLLocationCoordinate2D(latitude: 40.810079, longitude: -73.95961),
            CLLocationCoordinate2D(latitude: 40.810244, longitude: -73.9595),
            CLLocationCoordinate2D(latitude: 40.81035, longitude: -73.95978)
        ]
    ),
    DiningHall(
        name: "Chef Mike's Sub Shop",
        coordinates: [
            CLLocationCoordinate2D(latitude: 40.809345656117095, longitude: -73.96152053246136), // top left
            CLLocationCoordinate2D(latitude: 40.80902233784051, longitude: -73.96076438004125), //top right
            CLLocationCoordinate2D(latitude: 40.808590442331834, longitude:-73.96105785141016), // bottom right
            CLLocationCoordinate2D(latitude: 40.80893602192412, longitude: -73.96187375758686) //bottom left
        ]
    ),
    DiningHall( //
       name: "Chef Don's Pizza Pi",
       coordinates: [
           CLLocationCoordinate2D(latitude: 40.80961165997972, longitude:  -73.96033650655406), // top left
           CLLocationCoordinate2D(latitude: 40.809266791615634, longitude: -73.95953318495957), //top right
           CLLocationCoordinate2D(latitude: 40.80910438058197, longitude:-73.95965388436437), //bottom right
           CLLocationCoordinate2D(latitude: 40.809447473423454, longitude: -73.96045854706293) //bottom left
       ]
   ),

   DiningHall(
       name: "Diana Center Cafe",
       coordinates: [
   
           CLLocationCoordinate2D(latitude: 40.810165309313795, longitude: -73.96299318714298), // top left
           CLLocationCoordinate2D(latitude: 40.81005365328159, longitude: -73.9627222840346), //top right
           CLLocationCoordinate2D(latitude: 40.809559319318936, longitude: -73.96309108777157), // bottom right
           CLLocationCoordinate2D(latitude: 40.80961819296247, longitude: -73.96326140804298) //bottom left
       ]
   ),
   DiningHall(
       name: "Hewitt Dining",
       coordinates: [
           CLLocationCoordinate2D(latitude: 40.80847, longitude: -73.9648422), // bottom left
           CLLocationCoordinate2D(latitude: 40.80836, longitude: -73.96457), //bottom right
           CLLocationCoordinate2D(latitude: 40.80896, longitude: -73.964135), //top right
           CLLocationCoordinate2D(latitude: 40.8090612, longitude: -73.9643846) // top left
       
       ]
   )
]
