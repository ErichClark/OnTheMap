//
//  Structs.swift
//  OnTheMap
//
//  Created by Erich Clark on 8/30/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation

struct  StudentLocation {
    
    var objectID: String? // auto-generated id/key by Parse, uniquely identifies StudentLocation
    let key = Constants.Keys.UdacityID // Recommended as Udacity acc ID
    let firstName = Constants.Keys.FirstName // Hardcoded Fictional Names
    let lastName = Constants.Keys.LastName
    var mapString: String? // plain text for geocoding student location- "Mountain View, CA"
    let mediaURL = Constants.Keys.MediaURL // URL provided by the student
    var latitude: Float? // (ranges from -90 to 90)
    var longitude: Float? // (ranges from -180 to 180)
    var createdAt: Date? // When location was created
    var updatedAt: Date? // When last updated
    var ACL: String? // Parse Access Control List: permissions for StudentLoaction entry
}
