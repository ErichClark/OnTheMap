//
//  ClientConvenience.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/4/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Client Convenience Methods

extension MapClient {

    
    func loginToUdacity(username: String, password: String, _ completionHandlerForloginToUdacity: @escaping (_ success: Bool, _ sessionId: String?, _ errorString: String?) -> Void) {
        
        let postBody = SessionPOSTBody(udacity: Udacity(username: username, password: password))
        
        let parameters: [String:String] = [:]
        let method = MapClient.Methods.POSTUdacityForSession
        let _ = taskForPOSTMethod(method, parameters: parameters, postObject: postBody) { (results:POSTSessionResponseJSON?, errorString:String?) in
            
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
    
    func getAllStudentLocations(_ completionHandlerForGetLocations: @escaping (_ success: Bool, _ allStudentLocations: AllStudentLocations?, _ errorString: String?) -> Void) {
        
        let parameters: [String:String] = [:]
        let method = MapClient.Methods.AllStudents
        let _ = taskForGETMethod(method, parameters: parameters) { (results:AllStudentLocations?, errorString:String?) in
            
            if errorString != nil {
                completionHandlerForGetLocations(false, nil, errorString)
            } else if results?.results?.count == 0 {
                let errorString = "No student locations were returned"
                completionHandlerForGetLocations(false, nil, errorString)
            } else {
                print("** SUCCESS! At least one student location was found.")
                completionHandlerForGetLocations(true, results, nil)
            }
        }
    }
    
    private func getSingleStudentLocation(_ completionHandlerForGetSingleLocation: @escaping (_ success: Bool, _ singleStudentLocation: StudentLocation?, _ errorString: String?) -> Void) {
        
    }
    
    private func postStudentLocation(_ completionHandlerForPostStudentLocation: @escaping (_ success: Bool, _ postSessionResponseJSON: POSTSessionResponseJSON?, _ errorString: String?) -> Void) {
        
    }
    
    private func changeStudentLocation(_ completionHandlerForChangeLocation: @escaping (_ success: Bool, _ postSessionResponseJSON: POSTSessionResponseJSON?, _ errorString: String?) -> Void) {
        
    }
    
}
