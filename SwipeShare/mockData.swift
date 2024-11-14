//
//  mockData.swift
//  SwipeShare
//
//  Created by Rosa Figueroa on 11/13/24.
//

import SwiftUI
import MapKit
import CoreLocation

// giver struct
struct Giver: Identifiable {
    let id: String
    let name: String
    let year: String
    let coordinate: CLLocationCoordinate2D
    let profilePicture: Image
}

struct Receiver: Identifiable {
    let id: UUID
    let name: String
    let message: String
    let date: String
    let profileImage: Image
}

// function to check if a point is inside a polygon using Ray-Casting algorithm
func isPointInsidePolygon(point: CLLocationCoordinate2D, polygon: [CLLocationCoordinate2D]) -> Bool {
    var isInside = false
    let count = polygon.count

    for i in 0..<count {
        let j = (i + 1) % count
        let vertex1 = polygon[i]
        let vertex2 = polygon[j]

        if ((vertex1.latitude > point.latitude) != (vertex2.latitude > point.latitude)) &&
            (point.longitude < (vertex2.longitude - vertex1.longitude) * (point.latitude - vertex1.latitude) / (vertex2.latitude - vertex1.latitude) + vertex1.longitude) {
            isInside.toggle()
        }
    }
    return isInside
}

// get all givers in a dining hall based on their locations
func getGiversForDiningHall(givers: [Giver], diningHall: DiningHall) -> [Giver] {
    return givers.filter { giver in
        isPointInsidePolygon(point: giver.coordinate, polygon: diningHall.coordinates)
    }
}

// Define a DiningHall struct
struct DiningHall {
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
}

// mock givers
let givers: [Giver] = [
        Giver(id: UUID().uuidString, name: "Alice", year: "Sophomore at Barnard", coordinate: CLLocationCoordinate2D(latitude: 40.8057, longitude: -73.9621), profilePicture: Image("alice")),
        Giver(id: UUID().uuidString, name: "Joe", year: "Junior at Columbia", coordinate: CLLocationCoordinate2D(latitude: 40.8059, longitude: -73.9625), profilePicture: Image("joe")),
        Giver(id: UUID().uuidString, name: "Bob", year: "Senior at Columbia", coordinate: CLLocationCoordinate2D(latitude: 40.8068, longitude: -73.9638), profilePicture: Image("bob"))
]

// mock receivers
let receivers: [Receiver] = [
    Receiver(id: UUID(), name: "Jon", message: "requested a swipe", date: "11/14/24", profileImage: Image("joe")),
    Receiver(id: UUID(), name: "Lily", message: "requested a swipe", date: "11/12/24", profileImage: Image("alice")),
    Receiver(id: UUID(), name: "Sam", message: "requested a swipe", date: "11/10/24", profileImage: Image("bob")),
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
    )
]
