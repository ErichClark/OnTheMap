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
        let _ = taskForPOSTOrPUTMethod(address, optionalQueries: parameters, postObject: postBody, requestType: requestType) { (results:Data?, errorString:String?) in
            
            if errorString != nil {
                completionHandlerForloginToUdacity(false, nil, errorString)
            }

            if results == nil {
                let error = "No error was returned, but no data was returned either."
                completionHandlerForloginToUdacity(false, nil, error)
            }
            
            var accountResult: POSTSessionResponseJSON? = nil

            accountResult = self.decodeJSONResponse(data: results!, object: accountResult)
            
            let key = accountResult?.account.key
            let id = accountResult?.session.id
            MapClient.sharedInstance().accountKey = key
            MapClient.sharedInstance().sessionID = id
            
            if errorString != nil {
                completionHandlerForloginToUdacity(false, nil, errorString)
            } else if key == nil {
                let errorString = "No account key was returned from Udacity."
                completionHandlerForloginToUdacity(false, nil, errorString)
            } else if id == nil {
                let errorString = "No session ID was returned from Udacity."
                completionHandlerForloginToUdacity(false, nil, errorString)
            } else {
                let sessionID = id
                print("** SUCCESS! Session ID is \(String(describing: sessionID)), for user account key \(String(describing: key))")
                completionHandlerForloginToUdacity(true, sessionID, nil)
            }
        }
    }
    
    // TODO: - implement Log Out
    func logOutOfUdacity(_ completionHandlerForLogOutOfUdacity: @escaping (_ success: Bool, _ successMessage: String?, _ errorString: String?) -> Void) {
        
        
    }
    
    private func getSingleStudentLocation(_ completionHandlerForGetSingleLocation: @escaping (_ success: Bool, _ singleStudentLocation: StudentLocation?, _ errorString: String?) -> Void) {
        
    }
    
    // MARK: - POST or PUT ?
    
    func placeStudentLocationPin(newMediaURL: String?, mapString: String, latitude: Double, longitude: Double, _ completionHandlerForPutStudentLocation: @escaping (_ success: Bool, _ successMessage: String?, _ errorString: String?) -> Void) {
        
        let mediaURL = newMediaURL ?? MapClient.DummyUserData.MediaURLValue
        let objectId = MapClient.sharedInstance().userObjectId
        var address = MapClient.Addresses.ParseServerPostAddress
        var requestType = ""
        if objectId == nil {
            requestType = "POST"
            
        } else {
            requestType = "PUT"
            address.append("/" + objectId!)
        }
        

        self.requestHTTPStudentLocationPin(address: address, requestType: requestType, mediaURL: mediaURL, mapString: mapString, latitude: latitude, longitude: longitude) {  (success, successMessage, errorString) in
            
            if success {
                print("** Success! Location \(requestType) request was accepted.")
                completionHandlerForPutStudentLocation(true, successMessage, nil)
            } else {
                let errorMessage = "** Your \(requestType) was rejected because: \(String(describing: errorString))"
                completionHandlerForPutStudentLocation(false, nil, errorMessage)
            }
        }
    }
    
    func requestHTTPStudentLocationPin(address: String, requestType: String, mediaURL: String, mapString: String, latitude: Double, longitude: Double, _ completionHandlerForPutStudentLocation: @escaping (_ success: Bool, _ successMessage: String?, _ errorString: String?) -> Void) {
        
        let parameters: [String:String] = [:]
        
        let putStudentLocationJSON = POSTOrPutStudentLocationJSON(mediaURL: mediaURL, mapString: mapString, latitude: latitude, longitude: longitude)
        let _ = taskForPOSTOrPUTMethod(address, optionalQueries: parameters, postObject: putStudentLocationJSON, requestType: requestType) { (results:Data?, errorString:String?) in
            
            if errorString != nil {
                completionHandlerForPutStudentLocation(false, nil, errorString)
            } else if requestType == "POST" {
                var postResponse: POSTStudentLocationResponseJSON? = nil
                postResponse = self.decodeJSONResponse(data: results!, object: postResponse)
                var successMessage = "** SUCCESS! Your location has been set with "
                successMessage += "objectId \(String(describing: postResponse?.objectId)), "
                successMessage += "created at \(String(describing: postResponse?.createdAt))."
                completionHandlerForPutStudentLocation(true, successMessage, nil)
            }  else if requestType == "PUT" {
                var postResponse: PUTStudentLocationResponseJSON? = nil
                postResponse = self.decodeJSONResponse(data: results!, object: postResponse)
                var successMessage = "** SUCCESS! Your location has been updated "
                successMessage += "at \(String(describing: postResponse?.updatedAt))."
                completionHandlerForPutStudentLocation(true, successMessage, nil)
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
    
    func decodeJSONResponse<T: Decodable>(data: Data, object: T?) -> T? {
        // Verbose printing

        print("** MapClient is attempting to parse the following as a \(T.self) : \(String(describing: data))")
        print(String(data: data, encoding: .utf8)!)
        var jsonObject: T? = nil
        var errorMessage = ""
        var dataToParse = data
        
        if dataToParse == nil {
            return jsonObject
        }
        
        if T.self ==  POSTSessionResponseJSON.self || T.self == DeleteSessionResponseJSON.self {
            let range = (5..<data.count)
            let newData = data.subdata(in: range)
            dataToParse = newData
        }
        
        do {
            print(String(data: dataToParse, encoding: .utf8)!)
            let jsonDecoder = JSONDecoder()
            let jsonData = Data(dataToParse)
            jsonObject = try jsonDecoder.decode(T.self, from: jsonData)
        } catch {
            errorMessage = "** Could not parse JSON as \(T.self)"
            errorMessage += MapClient.parseUdacityError(data: data)
            print(errorMessage)
        }
        return jsonObject
    }
}
