//
//  DataFilter.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/24/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import MapKit

extension MapClient {
    
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
            // Captures our own objectId if we find our match and it has been lost locally.
            if student.uniqueKey == MapClient.sharedInstance().accountKey! {
                print("** Your unique key was found on the Udacity server.")
                if MapClient.sharedInstance().userObjectId == nil {
                    MapClient.sharedInstance().userObjectId = student.objectId
                }
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
}
