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
        
        let parameters: [String:String] = [:]
        let address = MapClient.Addresses.UdacityAPIAddress
        let _ = taskForPOSTMethod(address, optionalQueries: parameters, postObject: postBody) { (results:POSTSessionResponseJSON?, errorString:String?) in
            
            //            print("** Account key = \(results?.account.key)")
            //            print("** Session id = \(results?.session.id)")
            
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
    
    func get100ValidStudentLocations(_ completionHandlerForGet100ValidStudentLocations: @escaping (_ success: Bool, _ verifiedSudents: [VerifiedStudentPin]?, _ errorString: String?) -> Void ) {
        
        self.getAllStudentLocations() {
            (success, allStudentLocations, errorString) in
            
            
            if success {
                print("** SUCCESS! Unfiltered location list parsed.")
                self.filterInvalidLocations(allStudentLocations: allStudentLocations!) {
                    (success, verifiedStudents, errorString) in
                    
                    if success {
                        let filteredCount = verifiedStudents?.count
                        print("** SUCCESS! \(String(describing: filteredCount)) valid students were found.")
                        
                        // MARK: - Take only 100 verified entries
                        let slice = verifiedStudents![0..<100]
                        let oneHundredStudents = Array(slice)
                        MapClient.sharedInstance().allStudents = oneHundredStudents
                        completionHandlerForGet100ValidStudentLocations(true, verifiedStudents, nil)
                    }
                
                }
                
            }
        }
    }
    
    func getAllStudentLocations(_ completionHandlerForGetLocations: @escaping (_ success: Bool, _ allStudentLocations: AllStudentLocations?, _ errorString: String?) -> Void) {
        
        let address = MapClient.Addresses.ParseServerAddress
        let _ = taskForGETMethod(address, optionalQueries: nil) { (results:AllStudentLocations?, errorString:String?) in
            
            if results != nil {
                completionHandlerForGetLocations(true, results, nil)
            } else {
                completionHandlerForGetLocations(false, nil, errorString)
            }
        }
    }
    
    
    // MARK: - Filter bad location data, duplicates
    func filterInvalidLocations(allStudentLocations: AllStudentLocations, _ completionHandlerForFilterInvalidLocations: @escaping (_ success: Bool, _ cleanedStudentLocations: [VerifiedStudentPin]?, _ errorString: String?) -> Void ) {
        
        let potentialStudents: [StudentLocation] = allStudentLocations.results!
        var filteredStudents = [VerifiedStudentPin]()
        var BlacklistedUniqueKeys: [String] = [""]
        for student in potentialStudents {
            guard student.objectId != nil  else {
                continue
            }
            guard student.uniqueKey != nil  else {
                continue
            }
            guard !BlacklistedUniqueKeys.contains(student.uniqueKey!) else {
                continue
            }
            guard student.firstName != nil  else {
                continue
            }
            guard student.lastName != nil  else {
                continue
            }
            guard student.mapString != nil  else {
                continue
            }
            guard student.mediaURL != nil else {
                continue
            }
            guard let url = URL(string: student.mediaURL!) else {
                continue
            }
            guard student.latitude != nil  else {
                continue
            }
            guard Constants.ValidLatitudeRange.contains(student.latitude!) else {
                continue
            }
            guard student.longitude != nil  else {
                continue
            }
            guard Constants.ValidLongitudeRange.contains(student.longitude!) else {
                continue
            }
            guard student.createdAt != nil  else {
                continue
            }
            
            let cleanStudent = VerifiedStudentPin(firstName: student.firstName!, lastName: student.lastName!, url: url, latitude: student.latitude!, longitude: student.longitude!)
            filteredStudents.append(cleanStudent)
            BlacklistedUniqueKeys.append(student.uniqueKey!)
            
            // Captures our own objectId if we find our match and it has been lost locally.
            if student.uniqueKey == MapClient.sharedInstance().accountKey! {
                if MapClient.sharedInstance().userObjectId == nil {
                    MapClient.sharedInstance().userObjectId = student.objectId
                }
            }
        }
        
        let filteredCount = filteredStudents.count
        if  filteredCount > 0 {
            print("** SUCCESS! \(filteredCount) valid locations were found.")
            completionHandlerForFilterInvalidLocations(true, filteredStudents, nil)
        } else {
            let errorMessage = "Could not return cleaned Students array."
            completionHandlerForFilterInvalidLocations(false, nil, errorMessage)
        }
    }
    
    private func getSingleStudentLocation(_ completionHandlerForGetSingleLocation: @escaping (_ success: Bool, _ singleStudentLocation: StudentLocation?, _ errorString: String?) -> Void) {
        
    }
    
    func postStudentLocation(mediaURL: String, mapString: String, latitude: Double, longitude: Double, _ completionHandlerForPostStudentLocation: @escaping (_ success: Bool, _ postSessionResponseJSON: POSTStudentLocationResponseJSON?, _ errorString: String?) -> Void) {
        
        // Build the post object
        let postStudentLocationJSON = POSTorPUTStudentLocationJSON(mediaURL: mediaURL, mapString: mapString, latitude: latitude, longitude: longitude, objectId: MapClient.sharedInstance().userObjectId)
        
        var jsonBody: Data? = nil
        // Encode the object as a JSON
        do {
            let jsonEncoder = JSONEncoder()
            jsonBody = try jsonEncoder.encode(postStudentLocationJSON)
        }
        catch {
            let errorString = "** Could not encode JSON for posting student location: \(error)"
            completionHandlerForPostStudentLocation(false, nil, errorString)
        }
        
        let parameters: [String:String] = [:]
        let address = MapClient.Addresses.ParseServerPostAddress
        let _ = taskForPOSTMethod(address, optionalQueries: parameters, postObject: jsonBody) { (results:POSTStudentLocationResponseJSON?, errorString:String?) in
            
            //MapClient.sharedInstance().userObjectId = results.objectId
            
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
