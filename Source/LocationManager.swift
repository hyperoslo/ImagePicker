import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
  var locationManager = CLLocationManager()
  var latestLocation: CLLocation?
  var latestHeading: CLHeading?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
  }

  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
  }

  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
    locationManager.stopUpdatingHeading()
  }

  // MARK: - CLLocationManagerDelegate

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Pick the location with best (= smallest value) horizontal accuracy
    latestLocation = locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    self.latestHeading = newHeading
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      startUpdatingLocation()
    } else {
      stopUpdatingLocation()
    }
  }
}
