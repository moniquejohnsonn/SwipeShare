import SwiftUI
import MapKit

struct ReceiverHomeView2: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var selectedDiningHall: DiningHall? = nil
    @State private var navigateToReceiverHome = false
    
    
    
    // initial columbia/barnard view
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.80795368887853, longitude: -73.96237958464191),
        span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
    )
     
    var body: some View {
        ZStack {
            VStack (){
                // Custom Header
                HeaderView(
                    title: selectedDiningHall?.name ?? "Select a Dining Hall",
                    showBackButton: true,
                    onHeaderButtonTapped: {
                        navigateToReceiverHome = true
                    }
                )
                .frame(height: 150)
                
                ZStack() {
                    // map view
                    GeometryReader { geometry in
                        MapView(diningHalls: diningHalls, region: $region, selectedDiningHall: $selectedDiningHall)
                            .frame(width: geometry.size.width, height: 400) // sets fixed size to height of map
                    }
                    // Reset Button
                    VStack() {
                        HStack() {
                            Spacer()
                            Button(action: resetRegion) {
                                Text("See Entire Map")
                                    .font(.custom("BalooBhaina2-Regular", size: 13))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color("primaryPurple"))
                                    )
                            }
                        }
                        .padding(.trailing, 15)
                        .padding(.top, 15)
                        Spacer()
                    }
                }
                
                
                // givers table
                if let diningHall = selectedDiningHall {
                    VStack(alignment: .leading) {
                        // get the relevant givers for the selected dining hall
                        let relevantGivers = getGiversForDiningHall(givers: givers, diningHall: diningHall)
                        
                        GiversListView(givers: relevantGivers)
                    }
                    .frame(maxHeight: .infinity)
                    
                } else {
                    // default text in givers table half
                    VStack {
                        Spacer()
                        Text("Select Dining Hall to View Givers")
                            .font(.custom("BalooBhaina2-Regular", size: 20))
                            .padding(.top)
                            .frame(maxHeight: .infinity)
                        Spacer()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToReceiverHome) {
                ReceiverHomeView1()
            }
        }
    }
    
    // resets viewing region to original of all Columbia/Barnard
    private func resetRegion() {
        selectedDiningHall = nil
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.80795368887853, longitude: -73.96237958464191),
            span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        )
    }
}

struct GiverCardView: View {
    let giver: Giver
    @State private var navigateToGiverConfirm = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            giver.profilePicture
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color("secondaryGreen"), lineWidth: 6))
            
            // Giver details
            VStack(alignment: .leading, spacing: 2) {
                // Giver Name
                Text(giver.name)
                    .font(.custom("BalooBhaina2-Bold", size: 20))
                    .foregroundColor(Color("darkestPurple"))
                    .padding(.top, 20)
                    .fixedSize(horizontal: false, vertical: true)

                
                // Giver Year
                Text(giver.year)
                    .font(.custom("BalooBhaina2-Regular", size: 14))
                    .foregroundColor(Color("darkestPurple"))
                
                // Rating Section
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < 4 ? "star.fill" : "star")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(index < 4 ? Color.purple : Color.gray)
                    }
                }
                .padding(.bottom, 15)
            }
            
            Spacer()
            
            // Notification Bell Icon
            Button(action: {
                navigateToGiverConfirm = true
            }) {
                ZStack {
                    // Background square with rounded corners
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("secondaryGreen"))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "bell")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("darkestPurple"))
                        .scaledToFit()
                }
            }
            .padding(.trailing, 20)
        }
        .padding(.horizontal)
        .background(Color("lightestPurple"))
        .cornerRadius(16)
        .shadow(radius: 4)
        
        .navigationDestination(isPresented: $navigateToGiverConfirm) {
            MealSwipeRequestView()
        }
    }
}

struct GiversListView: View {
    let givers: [Giver]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("  Givers")
                .font(.custom("BalooBhaina2-Bold", size: 30))
                .foregroundColor(Color("primaryPurple"))
                .padding(.top, 15)
                .padding(.leading, 12)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(givers) { giver in
                        GiverCardView(giver: giver)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 20)
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct MapView: UIViewRepresentable {
    var diningHalls: [DiningHall]
    @Binding var region: MKCoordinateRegion
    @Binding var selectedDiningHall: DiningHall?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        
        // adds a tap gesture recognizer to detect taps
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)
        
        // draws each dining hall's boundaries
        for hall in diningHalls {
            let polygon = MKPolygon(coordinates: hall.coordinates, count: hall.coordinates.count)
            mapView.addOverlay(polygon)
            polygon.title = hall.name
            
            let relevantGivers = getGiversForDiningHall(givers: givers, diningHall: hall)
            // creates pins for givers
            for giver in relevantGivers {
                let annotation = MKPointAnnotation()
                annotation.coordinate = giver.coordinate
                annotation.title = giver.name
                annotation.subtitle = giver.year
                mapView.addAnnotation(annotation)
            }
        }
        
        return mapView
    }
    
    // updates view region
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
    }
    
    // creates coordinator to handle map events/interactions
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(diningHalls: diningHalls, region: $region, selectedDiningHall: $selectedDiningHall)
    }
}

class MapCoordinator: NSObject, MKMapViewDelegate {
    var diningHalls: [DiningHall]
    @Binding var region: MKCoordinateRegion // update the map's region
    @Binding var selectedDiningHall: DiningHall?  // tracks the selected dining hall
    
    // sets up the dining halls, region, and selected dining hall bindings
    init(diningHalls: [DiningHall], region: Binding<MKCoordinateRegion>, selectedDiningHall: Binding<DiningHall?>) {
        self.diningHalls = diningHalls
        _region = region
        _selectedDiningHall = selectedDiningHall
    }
    
    // renderer to display dining hall boundaries
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            // sets fill and outline color for the polygon
            renderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    // returns giver pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "GiverPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            // creates a new pin annotation view if it doesn't exist
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true  // info popup when tapped
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    // handles tap gestures on the map & selects corresponding dining hall
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let mapView = gestureRecognizer.view as! MKMapView  // gets the map view from the gesture recognizer
        let touchPoint = gestureRecognizer.location(in: mapView)  // gets the touch location on the map
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)  // convert touch point to coordinates
        
        // loop through dining halls and check if the tap was inside any
        for hall in diningHalls {
            let polygon = MKPolygon(coordinates: hall.coordinates, count: hall.coordinates.count)
            let renderer = MKPolygonRenderer(polygon: polygon)
            let mapPoint = MKMapPoint(touchCoordinate)
            let pointInRenderer = renderer.point(for: mapPoint)
            
            // if point inside polygon, update selected dining hall and region
            if renderer.path.contains(pointInRenderer) {
                selectedDiningHall = hall
                region = MKCoordinateRegion(
                    center: hall.centerCoordinate,  // set center of region
                    span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)  // sets the zoom level
                )
                break
            }
        }
    }

}
#Preview {
    ReceiverHomeView2()
}
