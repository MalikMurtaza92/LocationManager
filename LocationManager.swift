//
//  LocationManager.swift
//  LocationManager
//
//  Created by Murtaza Mehmood on 05/10/2024.
//

import Foundation
import CoreLocation

/// Enum representing the various authorization statuses for location services.
enum AuthorizationStatus: String {
    case notDetermined   /// Location authorization is not determined yet.
    case restricted      /// Location access is restricted (e.g., due to parental controls).
    case denied          /// Location access has been denied by the user.
    case authorizedAlways    /// Location access is allowed all the time.
    case authorizedWhenInUse /// Location access is allowed only when the app is in use.
    case unknown         /// Unknown or unexpected authorization status.
}

/// Protocol defining the responsibilities of a location manager.
protocol LocationManagerProtocol: AnyObject {
    /// The distance filter (in meters) that the location manager uses to determine when to send updates.
    var distanceFilter: Double { get set }
    
    /// Closure to handle location authorization errors, invoked when authorization is restricted or denied.
    var authorizationErrorHandler: ((AuthorizationStatus) -> Void)? { get set }
    
    /// Closure to handle errors that occur during location updates.
    var errorHandler: ((Error) -> Void)? { get set }
    
    /// Requests the location manager to start updating the location.
    func requestLocationUpdate()
}

/// Delegate protocol to receive location updates from the location manager.
protocol LocationManagerLocationDelegate: AnyObject {
    /// Method that is called when the location manager updates the current location.
    /// - Parameters:
    ///   - manager: The location manager providing the update.
    ///   - location: The new location data.
    func locationManager(_ manager: LocationManagerProtocol, didUpdateLocation location: CLLocation)
}

/// Class responsible for managing location services, adhering to the `LocationManagerProtocol`.
class LocationManager: NSObject, LocationManagerProtocol {
    
    /// The internal `CLLocationManager` instance responsible for interacting with the Core Location framework.
    private let locationManager: CLLocationManager
    
    /// Distance filter in meters to trigger location updates. The location manager will only report new locations
    /// if they have moved more than this distance.
    var distanceFilter: Double = 100
    
    /// The current authorization status of the location manager.
    var authorizationStatus: AuthorizationStatus = .notDetermined
    
    /// If true, the location manager will stop updating the location after the first successful update.
    var stopUpdatingAfterFirstLocation: Bool = true
    
    /// The most recent location, if available, as a `CLLocationCoordinate2D`.
    var location: CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    
    /// Closure to handle location authorization errors (restricted or denied statuses).
    var authorizationErrorHandler: ((AuthorizationStatus) -> Void)?
    
    /// Closure to handle general errors from the location manager.
    var errorHandler: ((Error) -> Void)?
    
    /// Delegate for receiving location updates from the `LocationManager`.
    var locationDelegate: LocationManagerLocationDelegate?
    
    /// Initializes a new instance of `LocationManager` and sets the delegate.
    override init() {
        locationManager = CLLocationManager()
        locationManager.distanceFilter = distanceFilter
        super.init()
        locationManager.delegate = self
    }
    
    /// Requests the location manager to start updating the location. If the authorization is denied, it triggers
    /// the `authorizationErrorHandler` closure.
    func requestLocationUpdate() {
        if authorizationStatus == .denied {
            authorizationErrorHandler?(.denied)
            return
        }
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    /// Called when the `CLLocationManager` updates its locations.
    /// - Parameters:
    ///   - manager: The location manager providing the update.
    ///   - locations: An array of `CLLocation` objects, with the most recent location at the end.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Stop updating location after the first update if flag is set.
        if stopUpdatingAfterFirstLocation {
            locationManager.stopUpdatingLocation()
        }
        // Extract the last location and inform the delegate.
        guard let location = locations.last else { return }
        locationDelegate?.locationManager(self, didUpdateLocation: location)
        print(location)
    }
    
    /// Called when an error occurs while updating the location.
    /// - Parameters:
    ///   - manager: The location manager that encountered the error.
    ///   - error: The error that occurred.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        // Call the error handler if one is provided.
        errorHandler?(error)
        print(error.localizedDescription)
    }
    
    /// Called when the location manager's authorization status changes.
    /// - Parameter manager: The location manager whose authorization status changed.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Update the authorization status and handle accordingly.
        switch manager.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            authorizationStatus = .restricted
            authorizationErrorHandler?(.restricted)
            
        case .denied:
            authorizationStatus = .denied
            authorizationErrorHandler?(.denied)
            
        case .authorizedAlways:
            authorizationStatus = .authorizedAlways
            locationManager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            locationManager.startUpdatingLocation()
            locationManager.requestAlwaysAuthorization()
            
        @unknown default:
            authorizationStatus = .unknown
            authorizationErrorHandler?(.unknown)
        }
    }
}

