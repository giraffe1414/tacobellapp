import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    private var locationManager: CLLocationManager?
    private var currentLevel = 1
    private var tacoViews: [UIImageView] = []
    private var distanceLabel: UILabel!
    private var scoreLabel: UILabel!
    private var levelLabel: UILabel!
    private let geocoder = CLGeocoder()
    private var animator: UIDynamicAnimator!
    private var gravity: UIGravityBehavior!
    private var collision: UICollisionBehavior!
    private var refreshControl: UIRefreshControl?
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupRefreshControl()
        setupDistanceLabel()
        setupScoreLabel()
        setupLevelLabel()
        setupPhysics()
    }
    
    private func setupLevelLabel() {
        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.textAlignment = .center
        levelLabel.font = .systemFont(ofSize: 18, weight: .medium)
        levelLabel.text = "Level: 1"
        view.addSubview(levelLabel)
        
        NSLayoutConstraint.activate([
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10),
            levelLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            levelLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupScoreLabel() {
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .center
        scoreLabel.font = .systemFont(ofSize: 18, weight: .bold)
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 10),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
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
        
        if #available(iOS 14.0, *) {
            switch locationManager?.authorizationStatus {
            case .notDetermined:
                locationManager?.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager?.requestLocation()
            case .denied, .restricted:
                distanceLabel.text = "Please enable location access in Settings"
            case .none:
                break
            @unknown default:
                break
            }
        } else {
            // Fallback on earlier versions
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager?.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager?.requestLocation()
            case .denied, .restricted:
                distanceLabel.text = "Please enable location access in Settings"
            @unknown default:
                break
            }
        }
    }
    
    private func setupRefreshControl() {
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
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
            if #available(iOS 13.0, *) {
                tacoView.image = UIImage(systemName: "fork.knife")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
            } else {
                // Fallback for older iOS versions
                tacoView.backgroundColor = .systemOrange
                tacoView.layer.cornerRadius = 20
            }
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
        
        // Increment score
        score += 1
        
        // Animate taco disappearing with a pop effect
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
            
            // Create new taco if all are gone
            if self.tacoViews.isEmpty {
                self.createTacos(for: self.currentLevel)
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager?.requestLocation()
        case .denied, .restricted:
            distanceLabel.text = "Please enable location access in Settings"
        default:
            break
        }
    }
    
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
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func updateLevel(distance: Double) {
        // Update level based on distance
        let newLevel: Int
        if distance <= 1 {
            newLevel = 5        // Less than 1 mile
        } else if distance <= 2 {
            newLevel = 4        // 1-2 miles
        } else if distance <= 3 {
            newLevel = 3        // 2-3 miles
        } else if distance <= 4 {
            newLevel = 2        // 3-4 miles
        } else {
            newLevel = 1        // More than 4 miles
        }
        
        // Only update if level changed
        if currentLevel != newLevel {
            currentLevel = newLevel
            levelLabel.text = "Level: \(currentLevel)"
            
            // Add level up animation
            UIView.animate(withDuration: 0.3, animations: {
                self.levelLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.levelLabel.transform = .identity
                }
            }
            
            // Create tacos for new level
            createTacos(for: currentLevel)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.distanceLabel.text = "Error getting location"
            self.refreshControl?.endRefreshing()
        }
    }
}
