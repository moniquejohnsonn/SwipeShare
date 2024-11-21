import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationAuthorized = false
    @Published var currentDiningHall: DiningHall?
    @Published var receiversInArea: [Receiver] = []

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization() // Required for geofencing
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // starts the process of continuously updating the user’s location
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        setupGeofences(for: diningHalls)
    }
    
    // Setup geofences for all dining halls
    private func setupGeofences(for diningHalls: [DiningHall]) {
        for hall in diningHalls {
            let region = CLCircularRegion(
                center: hall.centerCoordinate,
                radius: 50, // Geofence radius
                identifier: hall.name
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
    }
    
    // Geofence triggered (enter region)
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        
        // Match the region to a dining hall
        if let diningHall = diningHalls.first(where: { $0.name == circularRegion.identifier }) {
            DispatchQueue.main.async {
                self.currentDiningHall = diningHall
                self.receiversInArea = getReceiversForDiningHall(receivers: receivers, diningHall: diningHall)
            }
        }
        
        startUpdatingLocation()
        // TODO: send updated location to firebase
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
        
        // Stop location updates
        locationManager.stopUpdatingLocation()
        // TODO: send updated location to firebase
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationAuthorized = true
        } else {
            locationAuthorized = false
        }
    }
    
    // updates the giverLocation property with the most recent coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            DispatchQueue.main.async {
                self.userLocation = newLocation.coordinate
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
