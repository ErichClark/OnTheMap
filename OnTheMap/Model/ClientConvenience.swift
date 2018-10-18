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
        let address = DataSource.Addresses.UdacityAPIAddress
        let _ = taskForPOSTOrPUTMethod(address, optionalQueries: parameters, postObject: postBody, requestType: requestType) { (results:Data?, errorString:String?) in
            
            if errorString != nil {
                return completionHandlerForloginToUdacity(false, nil, errorString)
            }

            if results == nil {
                let errorString = "No error or data was returned."
                return completionHandlerForloginToUdacity(false, nil, errorString)
            }
            
            print("** Your results: ")
            print(String(data: results!, encoding: .utf8)!)
            
            var accountResult: POSTSessionResponseJSON? = nil
            accountResult = self.decodeJSONResponse(data: results!, object: accountResult)
            if accountResult == nil {
                var udacityError: UdacityError? = nil
                udacityError = self.decodeJSONResponse(data: results!, object: udacityError)
                let status: String = "\(udacityError!.status ?? 0)"
                let errorString = "\(udacityError?.error ?? "error")"
                let errorMessage = "\(status) - \(errorString)"
                return completionHandlerForloginToUdacity(false, nil, errorMessage)
            }
            // MARK: - Captures user's accountKey (elsewhere a uniqueKey)
            let key = accountResult?.account.key
            DataSource.sharedInstance().accountKey = key
            
            let id = accountResult?.session.id
            DataSource.sharedInstance().sessionID = id
            
            if errorString != nil {
                return completionHandlerForloginToUdacity(false, nil, errorString)
            } else if results == nil {
                let errorString = "Login failed."
                return completionHandlerForloginToUdacity(false, nil, errorString)
            } else if key == nil {
                let errorString = "No account key was returned."
                completionHandlerForloginToUdacity(false, nil, errorString)
            } else if id == nil {
                let errorString = "No session ID was returned."
                completionHandlerForloginToUdacity(false, nil, errorString)
            } else {
                let sessionID = id
                print("** SUCCESS! Session ID is \(String(describing: sessionID)), for user account key \(String(describing: key))")
                completionHandlerForloginToUdacity(true, sessionID, nil)
            }
        }
    }
    
    // MARK: - Log Out
    func logOutOfUdacity(_ completionHandlerForLogOutOfUdacity: @escaping (_ success: Bool, _ successMessage: String?, _ errorString: String?) -> Void) {
        
        var xrsfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xrsfCookie = cookie }
        }
        
        let _ = taskForDELETEMethod(xrsfCookie!) {(results, errorString) in
            if errorString != nil {
                completionHandlerForLogOutOfUdacity(false, nil, errorString)
            } else {
                var deleteResponse: DeleteSessionResponseJSON? = nil
                deleteResponse = self.decodeJSONResponse(data: results!, object: deleteResponse)

                let expiration = deleteResponse?.session.expiration
                
                let successMessage = "Successful logout at \(String(describing: expiration))."
                completionHandlerForLogOutOfUdacity(true, successMessage, nil)
            }
        }
    }
    
    private func updateArrayWithNewLocation(_ newLocation: VerifiedStudentPin) {
        // Removes student entry at old location
        // Inserts new entry at first position
        // Returns new array
        
        let userUniqueKey = DataSource.sharedInstance().accountKey

        let oldArray = DataSource.sharedInstance().allStudents
        var newArray: [VerifiedStudentPin] = [newLocation]
        var index = 0
        for student in oldArray! {
            if student.uniqueKey != userUniqueKey {
                newArray.append(student)
            } else {
                print("Old user location removed at index \(index)")
            }
            index += 1
        }
        DataSource.sharedInstance().allStudents = newArray
    }
    
    func placeStudentLocationPin(newMediaURL: String?, mapString: String, latitude: Double, longitude: Double, _ completionHandlerForPlaceStudentLocationPin: @escaping (_ success: Bool, _ newPin: VerifiedStudentPin?, _ errorString: String?) -> Void) {
        
        let mediaURL = newMediaURL ?? DataSource.DummyUserData.MediaURLValue
        
        let newPin = VerifiedStudentPin(
            firstName: DataSource.DummyUserData.FirstNameValue,
            lastName: DataSource.DummyUserData.LastNameValue,
            mapString: mapString,
            mediaURL: mediaURL,
            latitude: latitude,
            longitude: longitude,
            uniqueKey: DataSource.sharedInstance().accountKey, createdAt: nil, updatedAt: nil)
        
        
        let objectId = DataSource.sharedInstance().userObjectId
        var address = DataSource.Addresses.ParseServerAddress
        var requestType = ""
        if objectId == nil {
            requestType = "POST"
        } else {
            requestType = "PUT"
            address.append("/" + objectId!)
        }
        

        self.requestHTTPStudentLocationPin(newPin: newPin, address: address, requestType: requestType) {  (success, newPin, errorString) in
            
            if success {
                print("** Success! Location \(requestType) request accepted.")
                self.updateArrayWithNewLocation(newPin!)
                completionHandlerForPlaceStudentLocationPin(true, newPin, nil)
            } else {
                let errorMessage = "** Location \(requestType) rejected because: \(String(describing: errorString))"
                completionHandlerForPlaceStudentLocationPin(false, nil, errorMessage)
            }
        }
    }
    
    func requestHTTPStudentLocationPin(newPin: VerifiedStudentPin, address: String, requestType: String, _ completionHandlerForPutStudentLocation: @escaping (_ success: Bool, _ newPin: VerifiedStudentPin?, _ errorString: String?) -> Void) {
        
        let parameters: [String:String] = [:]
        
        let putStudentLocationJSON = POSTOrPutStudentLocationJSON(mediaURL: newPin.mediaURL, mapString: newPin.mapString, latitude: newPin.coordinate.latitude, longitude: newPin.coordinate.longitude)
        let _ = taskForPOSTOrPUTMethod(address, optionalQueries: parameters, postObject: putStudentLocationJSON, requestType: requestType) { (results:Data?, errorString:String?) in
            
            if errorString != nil {
                completionHandlerForPutStudentLocation(false, nil, errorString)
            } else if requestType == "POST" {
                var postResponse: POSTStudentLocationResponseJSON? = nil
                postResponse = self.decodeJSONResponse(data: results!, object: postResponse)
                var successMessage = "** SUCCESS! Your location has been set with "
                successMessage += "objectId \(String(describing: postResponse?.objectId)), "
                successMessage += "created at \(String(describing: postResponse?.createdAt))."
                print(successMessage)
                completionHandlerForPutStudentLocation(true, newPin, nil)
            }  else if requestType == "PUT" {
                var postResponse: PUTStudentLocationResponseJSON? = nil
                postResponse = self.decodeJSONResponse(data: results!, object: postResponse)
                var successMessage = "** SUCCESS! Your location has been updated "
                successMessage += "at \(String(describing: postResponse?.updatedAt))."
                print(successMessage)
                completionHandlerForPutStudentLocation(true, newPin, nil)
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
            
            completionHandlerForGetResultsFromStringQuery(true, response.mapItems, nil)
        }
    }
    
    func decodeJSONResponse<T: Decodable>(data: Data, object: T?) -> T? {
        var jsonObject: T? = nil
        var errorMessage = ""
        var dataToParse = data
        
        // Udacity prefixes 5 security characters
        // This method removes them
        if T.self ==  POSTSessionResponseJSON.self || T.self == DeleteSessionResponseJSON.self || T.self == UdacityError.self {
            let range = (5..<data.count)
            let newData = data.subdata(in: range)
            dataToParse = newData
        }
        
        do {
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
