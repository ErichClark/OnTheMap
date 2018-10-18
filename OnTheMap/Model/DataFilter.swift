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
    
    func getStudentLocations(_ completionHandlerForGet100ValidStudentLocations: @escaping (_ success: Bool, _ verifiedSudents: [VerifiedStudentPin]?, _ errorString: String?) -> Void ) {
        
        self.get100StudentLocations() {
            (success, allStudentLocations, errorString) in
            
            if allStudentLocations == nil {
                completionHandlerForGet100ValidStudentLocations(false, nil, "No student locations returned.")
            }
            if success {
                print("** SUCCESS! Unfiltered location list parsed.")
                self.filterInvalidResults(allStudentLocations: allStudentLocations!) {
                    (success, verifiedStudents, errorString) in
                    
                    if success {
                        let filteredCount = verifiedStudents?.count
                        print("** SUCCESS! \(String(describing: filteredCount)) valid students were found.")
                        
                        // MARK: - Take only 100 verified entries
                        DataSource.sharedInstance().allStudents = verifiedStudents
                        completionHandlerForGet100ValidStudentLocations(true, verifiedStudents, nil)
                    }
                }
            }
        }
    }
    
    func get100StudentLocations(_ completionHandlerForGetAllLocations: @escaping (_ success: Bool, _ allStudentLocations: AllStudentLocations?, _ errorString: String?) -> Void) {
        
        var address = MapClient.Addresses.ParseServerAddress
        // Asks for a specific number of entries from Udacity. Number is large because most entries are junk.
        address += "?limit=\(Constants.DefaultSampleSize)"
        let _ = taskForGETMethod(address, optionalQueries: nil) { (results:AllStudentLocations?, errorString:String?) in
            
            if results != nil {
                completionHandlerForGetAllLocations(true, results, nil)
            } else {
                completionHandlerForGetAllLocations(false, nil, errorString)
            }
        }
    }
    
    
    // MARK: - Filter bad location data, duplicates
    func filterInvalidResults(allStudentLocations: AllStudentLocations, _ completionHandlerForFilterInvalidLocations: @escaping (_ success: Bool, _ cleanedStudentLocations: [VerifiedStudentPin]?, _ errorString: String?) -> Void ) {
        
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
            if student.uniqueKey == DataSource.sharedInstance().accountKey {
                print("** Your location was found on the Udacity server at \(String(describing: student.mapString)).")
                DataSource.sharedInstance().userObjectId = student.objectId
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
            
            let cleanStudent = VerifiedStudentPin(
                firstName: student.firstName!,
                lastName: student.lastName!,
                mapString: student.mapString!,
                mediaURL: student.mediaURL!,
                latitude: student.latitude!,
                longitude: student.longitude!,
                uniqueKey: student.uniqueKey!)
            filteredStudents.append(cleanStudent)
            BlacklistedUniqueKeys.append(student.uniqueKey!)
        }
        
        let filteredCount = filteredStudents.count
        if  filteredCount > 0 {
            // print("** SUCCESS! \(filteredCount) valid locations were found.")
            completionHandlerForFilterInvalidLocations(true, filteredStudents, nil)
        } else {
            let errorMessage = "Could not return cleaned Students array."
            completionHandlerForFilterInvalidLocations(false, nil, errorMessage)
        }
    }
}
