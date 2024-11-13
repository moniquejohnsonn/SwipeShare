//  DiningHallView.swift
//
//  Created by Kalei Ragland on 11/12/24.
//


import SwiftUI
import MapKit

struct Giver: Identifiable {
    let id: String
    let name: String
    let year: String
    let coordinate: CLLocationCoordinate2D
}

struct DiningHall {
    let name: String
    let coordinates: [CLLocationCoordinate2D]
    let givers: [Giver]
    
    //calculates center coordinate of dining hall polygon to zoom in
    var centerCoordinate: CLLocationCoordinate2D {
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let avgLatitude = latitudes.reduce(0, +) / Double(latitudes.count)
        let avgLongitude = longitudes.reduce(0, +) / Double(longitudes.count)
        
        return CLLocationCoordinate2D(latitude: avgLatitude, longitude: avgLongitude)
    }
}

struct DiningHallView: View {
    // dining hall hardcoded coordinates and givers
    let diningHalls: [DiningHall] = [
          DiningHall(
                    name: "John Jay Dining Hall",
                    coordinates: [
                        CLLocationCoordinate2D(latitude: 40.805623, longitude: -73.9621324), // bottom right
                             CLLocationCoordinate2D(latitude: 40.8059040, longitude: -73.962835), //bottom left
                             CLLocationCoordinate2D(latitude: 40.806099, longitude: -73.9627), //top left
                             CLLocationCoordinate2D(latitude: 40.8058169, longitude: -73.961997) //top right
                    ],
                    givers: [
                        Giver(id: "1", name: "Alice", year: "Sophomore at Barnard", coordinate: CLLocationCoordinate2D(latitude: 40.8057, longitude: -73.9621)),
                        Giver(id: "2", name: "Joe", year: "Junior at Columbia", coordinate: CLLocationCoordinate2D(latitude: 40.80595031890182, longitude: -73.96255830253637))
                        
                    ]
                ),
                DiningHall(
                    name: "Ferris Booth Commons",
                    coordinates: [
                        CLLocationCoordinate2D(latitude: 40.8071641, longitude: -73.9640370), // top left
                        CLLocationCoordinate2D(latitude: 40.8069122, longitude: -73.96345), //top right
                        CLLocationCoordinate2D(latitude: 40.80652, longitude: -73.96375), // bottom right
                        CLLocationCoordinate2D(latitude: 40.8067554, longitude: -73.9643234) //bottom left
                    ],
                    givers: [
                        Giver(id: "3", name: "Bob", year: "Senior at Columbia", coordinate: CLLocationCoordinate2D(latitude: 40.8068848, longitude: -73.9638528))
                    ]
                ),
          // will make this region bigger so easier to tap
                DiningHall(
                    name: "Grace Dodge Dining Hall",
                    coordinates: [
                        CLLocationCoordinate2D(latitude: 40.8102, longitude:  -73.95989), // bottom left
                        CLLocationCoordinate2D(latitude: 40.810079, longitude: -73.95961), //bottom right
                        CLLocationCoordinate2D(latitude: 40.81024438859779, longitude:-73.9595), // right top
                        CLLocationCoordinate2D(latitude: 40.81035, longitude: -73.95978) //left top
                    ],
                    givers: [
                    ]
                ),
                
                DiningHall(//
                    name: "Chef Mike's Sub Shop",
                    coordinates: [
                        CLLocationCoordinate2D(latitude: 40.809345656117095, longitude: -73.96152053246136), // top left
                        CLLocationCoordinate2D(latitude: 40.80902233784051, longitude: -73.96076438004125), //top right
                        CLLocationCoordinate2D(latitude: 40.808590442331834, longitude:-73.96105785141016), // bottom right
                        CLLocationCoordinate2D(latitude: 40.80893602192412, longitude: -73.96187375758686) //bottom left
                    ],
                    givers: [
                    ]
                ),
                
                DiningHall( //
                    name: "Chef Don's Pizza Pi",
                    coordinates: [
                        CLLocationCoordinate2D(latitude: 40.80961165997972, longitude:  -73.96033650655406), // top left
                        CLLocationCoordinate2D(latitude: 40.809266791615634, longitude: -73.95953318495957), //top right
                        CLLocationCoordinate2D(latitude: 40.80910438058197, longitude:-73.95965388436437), //bottom right
                        CLLocationCoordinate2D(latitude: 40.809447473423454, longitude: -73.96045854706293) //bottom left
                    ],
                    givers: [
                    ]
                ),
            
                DiningHall(
                    name: "Diana Center Cafe",
                    coordinates: [
                
                        CLLocationCoordinate2D(latitude: 40.810165309313795, longitude: -73.96299318714298), // top left
                        CLLocationCoordinate2D(latitude: 40.81005365328159, longitude: -73.9627222840346), //top right
                        CLLocationCoordinate2D(latitude: 40.809559319318936, longitude: -73.96309108777157), // bottom right
                        CLLocationCoordinate2D(latitude: 40.80961819296247, longitude: -73.96326140804298) //bottom left
                    ],
                    givers: [
                    ]
                ),
                DiningHall(
                    name: "Hewitt Dining",
                    coordinates: [
                        CLLocationCoordinate2D(latitude: 40.80847, longitude: -73.9648422), // bottom left
                        CLLocationCoordinate2D(latitude: 40.80836, longitude: -73.96457), //bottom right
                        CLLocationCoordinate2D(latitude: 40.80896, longitude: -73.964135), //top right
                        CLLocationCoordinate2D(latitude: 40.8090612, longitude: -73.9643846) // top left
                    
                    ],
                    givers: [
                    ]
                )
            ]
      


    
    @State private var selectedDiningHall: DiningHall? = nil
    
    // initial columbia/barnard view
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.80795368887853, longitude: -73.96237958464191),
        span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
    )
     
    var body: some View {
        VStack {
            // Dining hall header
            HStack {
                Text(selectedDiningHall?.name ?? "Select a Dining Hall")
                    .font(.headline)
                    .padding()
                
                Spacer()
                // Reset button
                Button(action: resetRegion) {
                    Text("Reset View")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.trailing)
            }
            // map view
            GeometryReader { geometry in
                MapView(diningHalls: diningHalls, region: $region, selectedDiningHall: $selectedDiningHall)
                    .frame(width: geometry.size.width, height: 400) // sets fixed size to height of map
            }
           
            
            // givers table
            if let diningHall = selectedDiningHall {
                VStack(alignment: .leading) {
                    Text("  Givers")
                        .font(.headline)
                        .padding(.top, 44)
                    
                    List(diningHall.givers) {giver in
                        VStack(alignment: .leading) {
                            Text(giver.name)
                                .font(.subheadline)
                            Text("Year: \(giver.year)")
                                .font(.caption)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
            } else {
                // default text in givers table half
                VStack {
                            Spacer()
                            Text("Select Dining Hall to View Givers")
                                .font(.headline)
                                .padding(.top)
                                .frame(maxHeight: .infinity)
                            Spacer()
                        }
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
            
            // creates pins for givers
            for giver in hall.givers {
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
    DiningHallView()
}
