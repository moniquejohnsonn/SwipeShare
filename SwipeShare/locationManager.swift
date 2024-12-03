import CoreLocation
import Combine
import FirebaseAuth
import FirebaseFirestore

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationAuthorized = false
    @Published var currentDiningHall: DiningHall?
    
    weak var userProfileManager: UserProfileManager?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Setup geofences for all dining halls
    func setupGeofences(for diningHalls: [DiningHall]) {
        for hall in diningHalls {
            let region = CLCircularRegion(
                center: hall.centerCoordinate,
                radius: 100, // geofence radius
                identifier: hall.name
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
            print("SETUP FENCE FOR \(hall)")
        }
    }
    
    // Stop monitoring geofences
    func stopMonitoringGeofences() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    // Geofence triggered (enter region)
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        
        // Match the region to a dining hall
        if let diningHall = diningHalls.first(where: { $0.name == circularRegion.identifier }) {
            DispatchQueue.main.async {
                print("Entered \(diningHall.name)")
                self.currentDiningHall = diningHall
            }
        }
        
        // update the user's location after entering dining hall region
        updateUserLocationInFirebase()
    }

    // Geofence triggered (exit region)
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }

        // Clear dining hall when exiting
        if let diningHall = diningHalls.first(where: { $0.name == circularRegion.identifier }) {
            DispatchQueue.main.async {
                if self.currentDiningHall?.name == diningHall.name {
                    self.currentDiningHall = nil
                    print("Exited \(diningHall.name)")
                }
            }
        }
        
        // update the user's location after exiting dining hall region
        updateUserLocationInFirebase()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationAuthorized = true
            setupGeofences(for: diningHalls) // Setup geofences once authorized
        } else {
            locationAuthorized = false
        }
    }
    
    // updates the user location property with the most recent coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            DispatchQueue.main.async {
                self.userLocation = newLocation.coordinate
            }
        }
    }
    
    private func updateUserLocationInFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        guard let userLocation = self.userLocation else {
            print("User location not available")
            return
        }
        
        let geoPoint = GeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let diningHallName = currentDiningHall?.name ?? "None"
        
        userProfileManager?.updateUserLocation(uid: uid, location: geoPoint, diningHall: diningHallName) { error in
            if let error = error {
                print("Error updating user location: \(error.localizedDescription)")
            } else {
                print("User location updated successfully in Firebase.")
            }
        }
    }
    
    func updateCurrentDiningHall() {
        // Always request the user's location
        print("Requesting current location...")
        locationManager.requestLocation()

        // Guard against nil userLocation until the location is updated
        guard let userLocation = self.userLocation else {
            print("User location not available yet.")
            return
        }

        print("Validating current dining hall with user location: \(userLocation)")

        // Find the nearest dining hall within a certain distance threshold
        let nearbyDiningHall = diningHalls.first { diningHall in
            let hallLocation = CLLocation(latitude: diningHall.centerCoordinate.latitude, longitude: diningHall.centerCoordinate.longitude)
            let userLocationCL = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            return hallLocation.distance(from: userLocationCL) <= 50 // 50 meters threshold
        }

        DispatchQueue.main.async {
            self.currentDiningHall = nearbyDiningHall
        }

        updateUserLocationInFirebase()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
