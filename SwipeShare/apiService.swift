import Foundation


// properties of each school response
struct SchoolProperties: Codable {
    let name: String?
    let city: String?
    let postcode: String?
}

// structure for each school response
struct School: Codable, Identifiable, Hashable {
    // compute an id to be identified in views
    // uses school name by default
    var id = UUID()
    let properties: SchoolProperties
    let geometry: Geometry
    
    private enum CodingKeys: String, CodingKey {
       case properties, geometry // Exclude `id` from decoding
    }
    
    // Conform to Hashable by implementing hash(into:) if needed
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: School, rhs: School) -> Bool {
        return lhs.id == rhs.id
    }
}

// structure for the geometry (don't think we need it but just in case)
struct Geometry: Codable {
    let coordinates: [Double]
}

// main response structure
struct ApiResponse: Codable {
    let features: [School]
}


class APIService {
    let apiKey = "3de648c72fb04f728fdf134ebaa76cca"
    let latitude = 40.807590713673385
    let longitude = -73.96257924141334
    let radius = 10000 // aka 5 km
    
    func fetchUsers(completion: @escaping (Result<[School], Error>) -> Void) {
        guard let url = URL(string: "https://api.geoapify.com/v2/places?categories=education.university,education.college&filter=circle:\(longitude),\(latitude),\(radius)&bias=proximity:\(longitude),\(latitude)&limit=20&apiKey=\(apiKey)") else {
            print("Invalid URL")
            return
        }
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                }
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                let schools = apiResponse.features
                DispatchQueue.main.async {
                    completion(.success(schools))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
