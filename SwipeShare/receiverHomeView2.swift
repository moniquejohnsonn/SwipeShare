import SwiftUI
import MapKit

struct ReceiverHomeView2: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var selectedDiningHall: DiningHall? = nil
    @State private var navigateToReceiverHome = false
    @State private var selectedGiver: Giver? = nil
        
    // initial columbia/barnard view
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.80795368887853, longitude: -73.96237958464191),
        span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
    )
     
    var body: some View {
        ZStack {
            VStack (){
                // custom Header
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
                        MapView(diningHalls: diningHalls, region: $region, selectedDiningHall: $selectedDiningHall, selectedGiver: $selectedGiver)
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
                        
                        GiversListView(givers: relevantGivers, selectedGiver: $selectedGiver)

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
    @Binding var selectedGiver: Giver?
    
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
                    .foregroundColor((selectedGiver?.id == giver.id) ? Color.white : Color("darkestPurple"))
                    .padding(.top, 20)
                    .fixedSize(horizontal: false, vertical: true)

                
                // Giver Year
                Text(giver.year)
                    .font(.custom("BalooBhaina2-Regular", size: 14))
                    .foregroundColor((selectedGiver?.id == giver.id) ? Color.white : Color("darkestPurple"))
                
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
        .background((selectedGiver?.id == giver.id) ? Color("primaryPurple") : Color("lightestPurple"))
        .cornerRadius(16)
        .shadow(radius: 4)
        .onTapGesture {
            if selectedGiver?.id == giver.id {
                    selectedGiver = nil // Deselect if the same card is tapped
                } else {
                    selectedGiver = giver // Select this giver
                }
        }
        
        .navigationDestination(isPresented: $navigateToGiverConfirm) {
            MealSwipeRequestView()
        }
    }
}

struct GiversListView: View {
    let givers: [Giver]
    @Binding var selectedGiver: Giver?
    
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
                        GiverCardView(giver: giver, selectedGiver: $selectedGiver)
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
    @Binding var selectedGiver: Giver?
    
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
                let annotation = GiverAnnotation(
                    coordinate: giver.coordinate,
                    title: giver.name,
                    subtitle: giver.year,
                    profileImage: giver.profilePicture.asUIImage()
                )
                mapView.addAnnotation(annotation)
            }
        }
        
        return mapView
    }
    
    // updates view region
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        
        // Refresh annotations (remove and re-add them)
        uiView.removeAnnotations(uiView.annotations)
        for hall in diningHalls {
            let relevantGivers = getGiversForDiningHall(givers: givers, diningHall: hall)
            for giver in relevantGivers {
                let annotation = GiverAnnotation(
                    coordinate: giver.coordinate,
                    title: giver.name,
                    subtitle: giver.year,
                    profileImage: giver.profilePicture.asUIImage()
                )
                uiView.addAnnotation(annotation)
            }
        }

        // show annotation of the selected giver's pin (if any)
        if let selectedGiver = selectedGiver {
            if let annotation = uiView.annotations.first(where: {
                ($0 as? GiverAnnotation)?.title == selectedGiver.name
            }) {
                uiView.selectAnnotation(annotation, animated: true)
            }
        } else {
            // deselect all annotations if no giver is selected
            uiView.deselectAnnotation(nil, animated: true)
        }
    }
    
    // creates coordinator to handle map events/interactions
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(diningHalls: diningHalls, givers: givers, region: $region, selectedDiningHall: $selectedDiningHall, selectedGiver: $selectedGiver)
    }
}

class GiverAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let profileImage: UIImage
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, profileImage: UIImage) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.profileImage = profileImage
    }
}

class MapCoordinator: NSObject, MKMapViewDelegate {
    var diningHalls: [DiningHall]
    var givers: [Giver]
    @Binding var region: MKCoordinateRegion // update the map's region
    @Binding var selectedDiningHall: DiningHall?  // tracks the selected dining hall
    @Binding var selectedGiver: Giver?
    
    // sets up the dining halls, region, and selected dining hall and selected giver bindings
    init(diningHalls: [DiningHall],
         givers: [Giver],
         region: Binding<MKCoordinateRegion>,
         selectedDiningHall: Binding<DiningHall?>,
         selectedGiver: Binding<Giver?>
    ) {
        self.diningHalls = diningHalls
        self.givers = givers
        _region = region
        _selectedDiningHall = selectedDiningHall
        _selectedGiver = selectedGiver
    }
    
    // MARK: - Renderer for Dining Hall Overlays
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
    
    // MARK: - returns giver pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let giverAnnotation = annotation as? GiverAnnotation else { return nil }
        
        let identifier = "GiverPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: giverAnnotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // set the pin image
        annotationView?.image = createPinImage(
            for: giverAnnotation.profileImage,
            isSelected: giverAnnotation.title == selectedGiver?.name
        )
        annotationView?.centerOffset = CGPoint(x: 0, y: -(annotationView?.image?.size.height ?? 0) / 2)
                
        
        return annotationView
    }
    
    // MARK: - handle Pin Selection
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let giverAnnotation = view.annotation as? GiverAnnotation else { return }
        
        // find and set the selected giver
        if let giver = givers.first(where: { $0.name == giverAnnotation.title }) {
            selectedGiver = giver
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectedGiver = nil // clear the selection when a pin is deselected
    }

    
    
    private func createPinImage(for profileImage: UIImage, isSelected: Bool) -> UIImage? {
        let pinSize = CGSize(width: 50, height: 50)
        let profileSize = CGSize(width: 40, height: 40)
        
        UIGraphicsBeginImageContextWithOptions(pinSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // draw pin tip
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: pinSize.width / 2, y: pinSize.height - 2))
        context?.addLine(to: CGPoint(x: (pinSize.width / 2) - 10, y: profileSize.height - 2))
        context?.addLine(to: CGPoint(x: (pinSize.width / 2) + 10, y: profileSize.height - 2))
        context?.closePath()
        UIColor(named: "secondaryGreen")?.setFill() ?? UIColor.systemTeal.setFill()
        context?.fillPath()
        
        
        // draw the circle background for the profile picture
        let circleRect = CGRect(
            x: (pinSize.width - profileSize.width) / 2,
            y: 0,
            width: profileSize.width,
            height: profileSize.height
        )
        (isSelected ? UIColor(named: "primaryGreen") : UIColor(named: "secondaryGreen"))?.setFill()
        UIBezierPath(ovalIn: circleRect).fill()
        
        // draw the profile image
        let profileRect = circleRect.insetBy(dx: 5, dy: 5)
        let imageClipPath = UIBezierPath(ovalIn: profileRect)
        imageClipPath.addClip()
        profileImage.draw(in: profileRect)

        return UIGraphicsGetImageFromCurrentImageContext()
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

extension Image {
    func asUIImage() -> UIImage {
        // SwiftUI view for the image
        let view = self
            .resizable()
            .scaledToFill() // image fills the frame
            .clipShape(Circle()) // clips the image to a circle
            .frame(width: 100, height: 100) // Final size for the image

        // hosting controller for rendering
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        controller.view.backgroundColor = .clear

        // render the SwiftUI view into a UIImage
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}



#Preview {
    ReceiverHomeView2()
}
