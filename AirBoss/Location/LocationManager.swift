//
// Created for MyWeather
// by  Stewart Lynch on 2024-02-22
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import Foundation
import CoreLocation
import MapKit

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    @ObservationIgnored let manager = CLLocationManager()
    var userLocation: CLLocation?
    var currentLocation: HomeLocation?
    var isAuthorized = false
    
    var currentLocation2D: CLLocationCoordinate2D?
    var region: MKCoordinateRegion?

    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func startLocationServices() {
        if manager.authorizationStatus == .authorizedAlways ||
            manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = true  //: TODO
            isAuthorized = true
        } else {
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateAltitude locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        if let userLocation {
            print("Updated location")
            Task.detached { @MainActor in
                let name = await self.getLocationName(for: userLocation)
                self.currentLocation = HomeLocation(
                    name: name,
                    latitude: userLocation.coordinate.latitude,
                    longitude: userLocation.coordinate.longitude,
                    altitude: userLocation.altitude.magnitude * 3.281
                )
                self.currentLocation2D = CLLocationCoordinate2D(latitude: self.currentLocation?.latitude ?? 0, longitude: self.currentLocation?.longitude ?? 0)
                self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.currentLocation?.latitude ?? 0, longitude: self.currentLocation?.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0))
            }
        }
    }
    
    func getLocationName(for location: CLLocation) async -> String {
        let name = try? await CLGeocoder().reverseGeocodeLocation(location).first?.locality
        return name ?? ""
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
            manager.requestLocation()
        case .notDetermined:
            isAuthorized = true
            manager.requestWhenInUseAuthorization()
        case .denied:
            isAuthorized = false
        default:
            startLocationServices()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
