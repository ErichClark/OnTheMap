//
//  DataSource.swift
//  OnTheMap
//
//  Created by Erich Clark on 10/17/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import MapKit

class DataSource: NSObject {
    
    var allStudents: [VerifiedStudentPin]? = nil

    var sessionID: String? = nil
    var accountKey: String? = nil
    var currentLocation: CLLocationCoordinate2D? = nil
    var userObjectId: String? = nil
    var defaultRegion: MKCoordinateRegion? = nil
    
    
    // MARK: Shared Instance Singleton
    class func sharedInstance() -> DataSource {
        struct Singleton {
            static var sharedInstance = DataSource()
        }
        return Singleton.sharedInstance
    }
}
