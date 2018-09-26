//
//  ClientConvenience.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/4/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// MARK: - Client Convenience Methods

extension MapClient {
    
    func loginToUdacity(username: String, password: String, _ completionHandlerForloginToUdacity: @escaping (_ success: Bool, _ sessionId: String?, _ errorString: String?) -> Void) {
        
        let postBody = SessionPOSTBody(udacity: Udacity(username: username, password: password))
        let requestType = "POST"
        
        let parameters: [String:String] = [:]
        let address = MapClient.Addresses.UdacityAPIAddress
        let _ = taskForPOSTOrPUTMethod(address, optionalQueries: parameters, postObject: postBody, requestType: requestType) { (results:POSTSessionResponseJSON?, errorString:String?) in
            
            MapClient.sharedInstance().accountKey = results?.account.key
            MapClient.sharedInstance().sessionID = results?.session.id
            
            if errorString != nil {
                completionHandlerForloginToUdacity(false, nil, errorString)
            } else if results?.account.key == nil {
                let errorString = "No account key was returned from Udacity."
                completionHandlerForloginToUdacity(false, nil, errorString)
            } else if results?.session.id == nil {
                let errorString = "No session ID was returned from Udacity."
                completionHandlerForloginToUdacity(false, nil, errorString)
            } else {
                let sessionID = results?.session.id
                print("** SUCCESS! Session ID is \(String(describing: sessionID)), for user account key \(String(describing: results?.account.key))")
                completionHandlerForloginToUdacity(true, sessionID, nil)
            }
        }
        
    }
    
    private func getSingleStudentLocation(_ completionHandlerForGetSingleLocation: @escaping (_ success: Bool, _ singleStudentLocation: StudentLocation?, _ errorString: String?) -> Void) {
        
    }
    
    // MARK: - POST or PUT ?
    func postStudentLocation(mediaURL: String, mapString: String, latitude: Double, longitude: Double, _ completionHandlerForPostStudentLocation: @escaping (_ success: Bool, _ postSessionResponseJSON: POSTStudentLocationResponseJSON?, _ errorString: String?) -> Void) {
        
        let requestType = "POST"
        let parameters: [String:String] = [:]
        var address = MapClient.Addresses.ParseServerPostAddress
        
        // Either build a POST object
        if MapClient.sharedInstance().userObjectId == nil {
            let postStudentLocationJSON = POSTOrPutStudentLocationJSON(mediaURL: mediaURL, mapString: mapString, latitude: latitude, longitude: longitude)
            
            let _ = taskForPOSTOrPUTMethod(address, optionalQueries: parameters, postObject: postStudentLocationJSON, requestType: requestType) { (results:POSTStudentLocationResponseJSON?, errorString:String?) in
                
                if errorString != nil {
                    completionHandlerForPostStudentLocation(false, nil, errorString)
                } else {
                    print("** SUCCESS! You have posted your location successfully.")
                    // Verbose printing:
                    print("Your objectId is \(String(describing: results?.objectId)) created at \(String(describing: results?.createdAt))")
                    completionHandlerForPostStudentLocation(true, results, nil)
                }
            }
        }
    }
    
    func putStudentLocation(mediaURL: String, mapString: String, latitude: Double, longitude: Double, objectId: String, _ completionHandlerForPutStudentLocation: @escaping (_ success: Bool, _ postSessionResponseJSON: PUTStudentLocationResponseJSON?, _ errorString: String?) -> Void) {
        
        let requestType = "PUT"
        let parameters: [String:String] = [:]
        var address = MapClient.Addresses.ParseServerPostAddress
        address.append("/" + objectId)
        
        let putStudentLocationJSON = POSTOrPutStudentLocationJSON(mediaURL: mediaURL, mapString: mapString, latitude: latitude, longitude: longitude)
        let _ = taskForPOSTOrPUTMethod(address, optionalQueries: parameters, postObject: putStudentLocationJSON, requestType: requestType) { (results:PUTStudentLocationResponseJSON?, errorString:String?) in
            
            if errorString != nil {
                completionHandlerForPutStudentLocation(false, nil, errorString)
            } else {
                print("** SUCCESS! You have moved your location successfully.")
                completionHandlerForPutStudentLocation(true, results, nil)
            }
        }
    }
    
    
    func getResultsFromStringQuery(queryString: String, region: MKCoordinateRegion, completionHandlerForGetResultsFromStringQuery: @escaping (_ success: Bool?, _ results: [MKMapItem]?, _ errorString: String?) -> Void) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = queryString
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start() { (response, error) in
            
            guard let response = response else {
                let errorString = "There was an error searching for: \(String(describing: request.naturalLanguageQuery)) error: \(String(describing: error))"
                completionHandlerForGetResultsFromStringQuery(false, nil, errorString)
                return
            }
            
            if response.mapItems.count == 0 {
                let errorString = "No results found."
                completionHandlerForGetResultsFromStringQuery(false, nil, errorString)
            }
            
            // Verbose printing
            for item in response.mapItems {
                // Verbose printing
                let itemDetails = "** \(String(describing: item.name)) at \(item.placemark.coordinate.latitude) latitude and \(item.placemark.coordinate.longitude)"
                print(itemDetails)
                // Display the received items
            }
            
            completionHandlerForGetResultsFromStringQuery(true, response.mapItems, nil)
        }
    }
    
}
