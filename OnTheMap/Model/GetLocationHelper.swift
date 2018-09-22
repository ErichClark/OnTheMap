//
//  GetLocationHelper.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/19/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import CoreLocation

class GetLocationHelper {
    let locationManager = CLLocationManager()
    
    func returnOneLocation(_ completionHandlerForreturnOneLocation: @escaping (_ currentLocation: CLLocationCoordinate2D?, _ errorString: String?) -> Void ) {
        startReceivingLocationChanges() {
            (success, errorString) in
            
            if errorString != nil {
                completionHandlerForreturnOneLocation(nil, errorString)
            }
            let latitude = self.locationManager.location?.coordinate.latitude
            let longitude = self.locationManager.location?.coordinate.longitude
            let newCLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            // Verbose location printing
            print("** Your location has been read at lat \(String(describing: latitude)) and long \(String(describing: longitude))")
            self.locationManager.stopUpdatingLocation()
       
            completionHandlerForreturnOneLocation(newCLLocationCoordinate2D, nil)
        }
    }
    
    func startReceivingLocationChanges(_ completionHandlerForGetLocation: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // Check for permissions and service availability
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            completionHandlerForGetLocation(false, "User has not authorized access to location information.")
        } else if !CLLocationManager.locationServicesEnabled() {
            completionHandlerForGetLocation(false, "Location services is not available.")
        }
        
        // Start the service
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 10000
        //locationManager.delegate = self
        locationManager.startUpdatingLocation()
        completionHandlerForGetLocation(true, nil)
    }
    
    
}
