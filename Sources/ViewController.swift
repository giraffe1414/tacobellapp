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
        print("Creating tacos for level \(level)")
        
        // Remove existing tacos
        tacoViews.forEach { $0.removeFromSuperview() }
        tacoViews.removeAll()
        
        // Reset physics
        collision.removeAllBoundaries()
        collision.translatesReferenceBoundsIntoBoundary = true
        
        // Calculate taco count based on level
        let tacoCount = calculateTacoCount(for: level)
        print("Will create \(tacoCount) tacos")
        
        // Create and animate tacos
        DispatchQueue.main.async {
            for i in 0..<tacoCount {
                print("Creating taco \(i + 1) of \(tacoCount)")
                let randomX = CGFloat.random(in: 50...(self.view.bounds.width - 50))
                let tacoView = UIImageView(frame: CGRect(x: randomX, y: -50, width: 40, height: 40))
                if #available(iOS 13.0, *) {
                    let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
                    tacoView.image = UIImage(systemName: "takeoutbag.and.cup.and.straw.fill")?
                        .withConfiguration(config)
                        .withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
                } else {
                    // Fallback for older iOS versions
                    tacoView.backgroundColor = .systemOrange
                    tacoView.layer.cornerRadius = 20
                }
                tacoView.contentMode = .scaleAspectFit
                tacoView.isUserInteractionEnabled = true
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tacoTapped(_:)))
                tacoView.addGestureRecognizer(tapGesture)
                
                self.view.addSubview(tacoView)
                self.tacoViews.append(tacoView)
                
                // Add physics
                self.gravity.addItem(tacoView)
                self.collision.addItem(tacoView)
                
                // Add rotation
                let rotation = UIDynamicItemBehavior(items: [tacoView])
                rotation.addAngularVelocity(CGFloat.random(in: -2...2), for: tacoView)
                rotation.elasticity = 0.5
                self.animator.addBehavior(rotation)
            }
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
        guard let location = locations.last else { return }
        
        // Prevent multiple rapid location updates
        locationManager?.stopUpdatingLocation()
        
        print("Location update received")
        
        // Search for nearby Taco Bell locations
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "Taco Bell"
        searchRequest.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    self.distanceLabel.text = "Error finding Taco Bell locations"
                    self.refreshControl?.endRefreshing()
                    return
                }
                
                guard let nearestTacoBell = response?.mapItems.first else {
                    print("No Taco Bell locations found")
                    self.distanceLabel.text = "No Taco Bell locations found nearby"
                    self.refreshControl?.endRefreshing()
                    return
                }
                
                let distance = location.distance(from: nearestTacoBell.placemark.location!)
                let distanceInMiles = distance / 1609.34 // Convert meters to miles
                
                print("Found Taco Bell at \(distanceInMiles) miles")
                self.distanceLabel.text = String(format: "Nearest Taco Bell: %.1f miles", distanceInMiles)
                self.updateLevel(distance: distanceInMiles)
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func calculateTacoCount(for level: Int) -> Int {
        let count: Int
        switch level {
        case 1: count = 2
        case 2: count = 5
        case 3: count = 11
        case 4: count = 17
        case 5: count = 25
        default: count = 2
        }
        return count
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
        
        print("Distance: \(distance) miles, Level: \(newLevel)")
        
        // Update level and create tacos
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
        
        // Always create new tacos when level is updated
        createTacos(for: currentLevel)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.distanceLabel.text = "Error getting location"
            self.refreshControl?.endRefreshing()
        }
    }
}
