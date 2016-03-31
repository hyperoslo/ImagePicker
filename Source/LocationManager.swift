import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
  var locationManager = CLLocationManager()
  var latestLocation: CLLocation?
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
  }
  
  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }
  
  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
  }
  
  // MARK: - CLLocationManagerDelegate
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Pick the location with best (= smallest value) horizontal accuracy
    latestLocation = locations.sort{ $0.horizontalAccuracy < $1.horizontalAccuracy }.first
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
      locationManager.startUpdatingLocation()
    } else {
      locationManager.stopUpdatingLocation()
    }
  }
}
