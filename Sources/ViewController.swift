import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    private var locationManager: CLLocationManager?
    private var currentLevel = 1
    private var tacoViews: [UIImageView] = []
    private var distanceLabel: UILabel!
    private let geocoder = CLGeocoder()
    private var animator: UIDynamicAnimator!
    private var gravity: UIGravityBehavior!
    private var collision: UICollisionBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupRefreshControl()
        setupDistanceLabel()
        setupPhysics()
    }
    
    private func setupPhysics() {
        animator = UIDynamicAnimator(referenceView: view)
        
        gravity = UIGravityBehavior()
        gravity.magnitude = 0.8
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior()
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
    }
    
    private func setupDistanceLabel() {
        distanceLabel = UILabel()
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.textAlignment = .center
        distanceLabel.font = .systemFont(ofSize: 18)
        distanceLabel.text = "Finding nearest Taco Bell..."
        view.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            distanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            distanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            distanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func setupRefreshControl() {
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        view.insertSubview(scrollView, at: 0)
    }
    
    @objc private func refreshContent() {
        // Clear existing tacos
        tacoViews.forEach { $0.removeFromSuperview() }
        tacoViews.removeAll()
        
        // Request location update
        locationManager?.requestLocation()
    }
    
    private func createTacos(for level: Int) {
        // Remove existing tacos
        tacoViews.forEach { $0.removeFromSuperview() }
        tacoViews.removeAll()
        
        // Reset physics
        collision.removeAllBoundaries()
        collision.translatesReferenceBoundsIntoBoundary = true
        
        let tacoCount: Int
        switch level {
        case 1: tacoCount = 2
        case 2: tacoCount = 5
        case 3: tacoCount = 11
        case 4: tacoCount = 17
        case 5: tacoCount = 25
        default: tacoCount = 2
        }
        
        // Create and animate tacos
        for _ in 0..<tacoCount {
            let randomX = CGFloat.random(in: 50...(view.bounds.width - 50))
            let tacoView = UIImageView(frame: CGRect(x: randomX, y: -50, width: 40, height: 40))
            tacoView.image = UIImage(named: "taco")
            tacoView.contentMode = .scaleAspectFit
            tacoView.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tacoTapped(_:)))
            tacoView.addGestureRecognizer(tapGesture)
            
            view.addSubview(tacoView)
            tacoViews.append(tacoView)
            
            // Add physics
            gravity.addItem(tacoView)
            collision.addItem(tacoView)
            
            // Add rotation
            let rotation = UIDynamicItemBehavior(items: [tacoView])
            rotation.angularVelocity = CGFloat.random(in: -2...2)
            rotation.elasticity = 0.5
            animator.addBehavior(rotation)
        }
    }
    
    @objc private func tacoTapped(_ gesture: UITapGestureRecognizer) {
        guard let tacoView = gesture.view as? UIImageView else { return }
        
        // Animate taco disappearing
        UIView.animate(withDuration: 0.3, animations: {
            tacoView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            tacoView.alpha = 0
        }) { _ in
            // Remove from physics and view
            self.gravity.removeItem(tacoView)
            self.collision.removeItem(tacoView)
            tacoView.removeFromSuperview()
            if let index = self.tacoViews.firstIndex(of: tacoView) {
                self.tacoViews.remove(at: index)
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Search for nearby Taco Bell locations
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "Taco Bell"
        searchRequest.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                self.distanceLabel.text = "Error finding Taco Bell locations"
                return
            }
            
            guard let nearestTacoBell = response?.mapItems.first else {
                self.distanceLabel.text = "No Taco Bell locations found nearby"
                return
            }
            
            let distance = location.distance(from: nearestTacoBell.placemark.location!)
            let distanceInMiles = distance / 1609.34 // Convert meters to miles
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.distanceLabel.text = String(format: "Nearest Taco Bell: %.1f miles", distanceInMiles)
                self.updateLevel(distance: distanceInMiles)
            }
        }
    }
    
    private func updateLevel(distance: Double) {
        // Update level based on distance
        currentLevel = switch distance {
            case 0...1: 5    // Less than 1 mile
            case 1...2: 4    // 1-2 miles
            case 2...3: 3    // 2-3 miles
            case 3...4: 2    // 3-4 miles
            default: 1       // More than 4 miles
        }
        
        // Create tacos for current level
        createTacos(for: currentLevel)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
