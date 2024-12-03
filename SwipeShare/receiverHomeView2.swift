import SwiftUI
import MapKit
import FirebaseFirestore

struct ReceiverHomeView2: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var locationManager: LocationManager
    @Binding var selectedDiningHall: DiningHall?
    @State private var navigateToReceiverHome = false

    @State private var selectedGiver: UserProfile? = nil
    @State private var relevantGivers: [UserProfile] = []
    @State private var region: MKCoordinateRegion

    
    // custom initializer
    init(selectedDiningHall: Binding<DiningHall?>) {
        _selectedDiningHall = selectedDiningHall
        
        //default columbia region
        let defaultRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.80795368887853, longitude: -73.96237958464191),
            span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        )
        //selected hall region
        let selectedRegion = MKCoordinateRegion(
            center: selectedDiningHall.wrappedValue?.centerCoordinate ?? defaultRegion.center,
            span: MKCoordinateSpan(
                latitudeDelta: selectedDiningHall.wrappedValue == nil ? defaultRegion.span.latitudeDelta : 0.0015,
                longitudeDelta: selectedDiningHall.wrappedValue == nil ? defaultRegion.span.longitudeDelta : 0.0015
            )
        )
        _region = State(initialValue: selectedRegion)
    }
    
    var body: some View {

        NavigationStack {
            ScrollView {
                VStack {
                    HeaderView(
                        title: selectedDiningHall?.name ?? "Select a Dining Hall",
                        showBackButton: true,
                        onHeaderButtonTapped: {
                            navigateToReceiverHome = true
                        }
                    )
                    .frame(height: 150)
                    .onAppear {
                        locationManager.updateCurrentDiningHall()
                        if let hall = selectedDiningHall {
                            fetchGiversForSelectedDiningHall()
                            region = MKCoordinateRegion(
                                center: hall.centerCoordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
                            )
                        }
                    }
                    
                    
                    ZStack {
                        MapView(
                            diningHalls: diningHalls,
                            region: $region,
                            selectedDiningHall: $selectedDiningHall,
                            selectedGiver: $selectedGiver
                        )
                        .frame(height: 400)
                        // "See Entire Map" Button
                        
                        VStack {
                            HStack {
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
                                .padding(.trailing, 15)
                                .padding(.top, 15)
                            }
                            Spacer()
                        }
                    }
                    
                    if selectedDiningHall != nil {
                        VStack(alignment: .leading) {
                            GiversListView(
                                givers: relevantGivers,
                                selectedGiver: $selectedGiver,
                                selectedDiningHall: $selectedDiningHall
                            )
                        }
                        .onAppear {
                            fetchGiversForSelectedDiningHall()
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        Text("Select a Dining Hall to View Givers")
                            .font(.headline)
                            .frame(maxHeight: .infinity)
                    }
                }
                .navigationDestination(isPresented: $navigateToReceiverHome) {
                    ReceiverHomeView1()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }

    private func fetchGiversForSelectedDiningHall() {
        guard let diningHall = selectedDiningHall else {
            relevantGivers = []
            return
        }

        userProfileManager.getUsersForDiningHall(role: "giver", diningHall: diningHall, includeMock: false) { givers in
            let dispatchGroup = DispatchGroup()
            var updatedGivers: [UserProfile] = []

            for giver in givers {
                var giverCopy = giver
                dispatchGroup.enter()
                userProfileManager.fetchProfilePicture(for: giver) { image in
                    giverCopy.profilePicture = image
                    updatedGivers.append(giverCopy)
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.relevantGivers = updatedGivers.sorted { $0.name < $1.name } // Example sort by name
            }
        }
    }
    
    // resets viewing region to default Columbia/Barnard view
    private func resetRegion() {
        selectedGiver = nil
        selectedDiningHall = nil
        relevantGivers = []
        
        print("selctedDiningHall after reset: \(String(describing: selectedDiningHall))")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 40.80795368887853, longitude: -73.96237958464191),
                    span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
                )
        }
    }
}


struct GiverCardView: View {
    let giver: UserProfile
    
    @State private var navigateToGiverConfirm = false
    @Binding var selectedGiver: UserProfile?
    @Binding var selectedDiningHall: DiningHall?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(uiImage: giver.profilePicture ?? UIImage())
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
                Text("\(giver.year) at \(giver.campus)")
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
            if let diningHall = selectedDiningHall {
                MealSwipeRequestView(giver: giver, diningHall: diningHall)
            } else {
                Text("Please select a dining hall.")
            }
            
        }
    }
}
    
    
struct GiversListView: View {
    let givers: [UserProfile]
        @Binding var selectedGiver: UserProfile?
        @Binding var selectedDiningHall: DiningHall?

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                headerView
                
                content
            }
            .padding(.top, 20)
            .background(Color.white)
            .cornerRadius(16)
        }

        // MARK: - Header View
        private var headerView: some View {
            Text("Givers")
                .font(.custom("BalooBhaina2-Bold", size: 30))
                .foregroundColor(Color("primaryPurple"))
                .padding(.top, 10)
                .padding(.leading, 12)
        }

        // MARK: - Content View
        private var content: some View {
            Group {
                if selectedDiningHall == nil {
                    noDiningHallSelectedView
                } else if givers.isEmpty {
                    noGiversView
                } else {
                    giversList
                }
            }
        }

        // MARK: - No Dining Hall Selected
        private var noDiningHallSelectedView: some View {
            Text("Select a dining hall to view givers.")
                .font(.custom("BalooBhaina2-Regular", size: 18))
                .foregroundColor(Color.gray)
                .padding(.top, 20)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .center)
        }

        // MARK: - No Givers Available
        private var noGiversView: some View {
            Text("No givers at \(selectedDiningHall?.name ?? "this dining hall").")
                .font(.custom("BalooBhaina2-Regular", size: 18))
                .foregroundColor(Color.gray)
                .padding(.top, 20)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .center)
        }

        // MARK: - Givers List
        private var giversList: some View {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(givers) { giver in
                        GiverCardView(
                            giver: giver,
                            selectedGiver: $selectedGiver,
                            selectedDiningHall: $selectedDiningHall
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
}
    
struct MapView: UIViewRepresentable {
    @EnvironmentObject var userProfileManager: UserProfileManager
    var diningHalls: [DiningHall]
    @Binding var region: MKCoordinateRegion
    @Binding var selectedDiningHall: DiningHall?
    @Binding var selectedGiver: UserProfile?
    @State private var allGivers: [UserProfile] = []

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)

        // Add tap gesture recognizer to detect taps
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)

        // Draw dining hall boundaries
        for diningHall in diningHalls {
            let polygon = MKPolygon(coordinates: diningHall.coordinates, count: diningHall.coordinates.count)
            mapView.addOverlay(polygon)
            polygon.title = diningHall.name
        }

        // Fetch all givers asynchronously
        fetchAllGivers(mapView: mapView)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)

        let existingAnnotations = uiView.annotations.compactMap { $0 as? GiverAnnotation }

        for giver in allGivers {
            if let location = giver.location,
               !existingAnnotations.contains(where: { $0.title == giver.name }) {
                let annotation = GiverAnnotation(
                    location: location,
                    title: giver.name,
                    subtitle: giver.year,
                    profileImage: giver.profilePicture ?? UIImage(named: "profilePicHolder")!
                )
                uiView.addAnnotation(annotation)
            }
        }

        let giverNames = allGivers.map { $0.name }
        for annotation in existingAnnotations {
            if !giverNames.contains(annotation.title ?? "") {
                uiView.removeAnnotation(annotation)
            }
        }

        if let selectedGiver = selectedGiver {
            if let annotation = uiView.annotations.first(where: { ($0 as? GiverAnnotation)?.title == selectedGiver.name }) {
                uiView.selectAnnotation(annotation, animated: true)
            }
        } else {
            uiView.deselectAnnotation(nil, animated: true)
        }
    }

    // Fetch all givers across dining halls
    private func fetchAllGivers(mapView: MKMapView) {
        var fetchedGivers: [UserProfile] = []
        let dispatchGroup = DispatchGroup()

        for diningHall in diningHalls {
            userProfileManager.getUsersForDiningHall(role: "giver", diningHall: diningHall, includeMock: false) { relevantGivers in
                for giver in relevantGivers {
                    dispatchGroup.enter()
                    var giverWithPicture = giver
                    userProfileManager.fetchProfilePicture(for: giver) { image in
                        giverWithPicture.profilePicture = image
                        if let location = giverWithPicture.location {
                            DispatchQueue.main.async {
                                let annotation = GiverAnnotation(
                                    location: location,
                                    title: giverWithPicture.name,
                                    subtitle: "\(giverWithPicture.year) at \(giverWithPicture.campus)",
                                    profileImage: giverWithPicture.profilePicture ?? UIImage(named: "profilePicHolder")!
                                )
                                mapView.addAnnotation(annotation)
                            }
                        }
                        fetchedGivers.append(giverWithPicture)
                        dispatchGroup.leave()
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            // Update `allGivers` after all profile pictures are fetched
            self.allGivers = fetchedGivers.sorted { $0.name < $1.name } // Example: Sort by name
            print("All givers with profile pictures loaded.")
        }
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(
            diningHalls: diningHalls,
            allGivers: $allGivers,
            region: $region,
            selectedDiningHall: $selectedDiningHall,
            selectedGiver: $selectedGiver
        )
    }
}
    
class GiverAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let profileImage: UIImage

    init(location: GeoPoint, title: String?, subtitle: String?, profileImage: UIImage) {
        // Convert GeoPoint to CLLocationCoordinate2D
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        self.title = title
        self.subtitle = subtitle
        self.profileImage = profileImage
    }
}
    
    class MapCoordinator: NSObject, MKMapViewDelegate {
        var diningHalls: [DiningHall]
        @Binding var allGivers: [UserProfile]
        @Binding var region: MKCoordinateRegion // update the map's region
        @Binding var selectedDiningHall: DiningHall?  // tracks the selected dining hall
        @Binding var selectedGiver: UserProfile?
        
        // sets up the dining halls, region, and selected dining hall and selected giver bindings
        init(diningHalls: [DiningHall],
             allGivers: Binding<[UserProfile]>,
             region: Binding<MKCoordinateRegion>,
             selectedDiningHall: Binding<DiningHall?>,
             selectedGiver: Binding<UserProfile?>
        ) {
            self.diningHalls = diningHalls
            _allGivers = allGivers
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
            if let giver = allGivers.first(where: { $0.name == giverAnnotation.title }) {
                selectedGiver = giver
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            DispatchQueue.main.async {
                self.selectedGiver = nil // clear the selection when a pin is deselected
            }
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
                    self.selectedDiningHall = hall
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
    @Previewable @State var mockSelectedDiningHall: DiningHall? = nil
        let mockUserProfileManager = UserProfileManager()
        return ReceiverHomeView2(selectedDiningHall: $mockSelectedDiningHall)
            .environmentObject(mockUserProfileManager)
}
