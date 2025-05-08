import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    private var locationManager: CLLocationManager?
    private var currentLevel = 1
    private var tacoViews: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController loaded")
        setupLocationManager()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController: viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewController: viewDidAppear")
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
        view.addSubview(scrollView)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    @objc private func refreshContent() {
        // Clear existing tacos
        tacoViews.forEach { $0.removeFromSuperview() }
        tacoViews.removeAll()
        
        // Request location update
        locationManager?.requestLocation()
    }
    
    private func createTacos(for level: Int) {
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
            let tacoView = UIImageView(frame: CGRect(x: 0, y: -50, width: 50, height: 50))
            // Set taco image
            // Add physics behavior
            // Add tap gesture
            view.addSubview(tacoView)
            tacoViews.append(tacoView)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Find nearest Taco Bell and determine level
        // Update UI based on distance
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
