//
//  Structs.swift
//  OnTheMap
//
//  Created by Erich Clark on 8/30/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation

struct AllStudentLocationsJSON: Decodable {
    var results: [StudentLocation]?
}

struct  StudentLocation: Decodable {
    
        var objectID: String? // auto-generated id/key by Parse, uniquely identifies StudentLocation
        var uniqueKey: String?
        var firstName: String?
        var lastName: String? //= Constants.Keys.LastName
        var mapString: String? // plain text for geocoding student location- "Mountain View, CA"
        var mediaURL:String? //= Constants.Keys.MediaURL // URL provided by the student
        var latitude: Double? // (ranges from -90 to 90)
        var longitude: Double? // (ranges from -180 to 180)
        var createdAt: Date? // When location was created
        var updatedAt: Date? // When last updated
        var ACL: String? // Parse Access Control List: permissions for StudentLoaction entry
}

struct POSTorPUTStudentLocationJSON: Encodable {
    let uniqueKey: String = MapClient.Constants.UdacityIDValue // Recommended as Udacity acc ID
    let firstName: String = MapClient.Constants.FirstNameValue
    let lastName: String  = MapClient.Constants.LastNameValue
    let mediaURL:String = MapClient.Constants.MediaURLValue // URL provided by the student
    
    let mapString: String // plain text for geocoding student location- "Mountain View, CA"
    let latitude: Double // (ranges from -90 to 90)
    let longitude: Double // (ranges from -180 to 180)
    // TODO: - Can a POST request be made if the objectID=nil value is sent?
    // The only difference between PUT and POST is this key:value
    let objectID: String? // For PUT auto-generated id/key by Parse, uniquely identifies StudentLocation
}

struct MapErrorJSON {
    // TODO: -
}

struct GetUdacityUserDataJSONResponse: Decodable {
     var user: UdacityUser
}

struct UdacityUser: Decodable {
    var last_name: String?
    var first_name: String?
    var key: Int?
    var website_url: String?
}

struct POSTSessionResponseJSON: Decodable {
    var account: Account
    var session: Session
}

struct Account: Decodable {
    var registered: Bool
    var key: Int
}

struct Session: Decodable {
    var id: String
    var expiration: Date
}

struct POSTStudentLocationResponseJSON: Decodable {
    var createdAt: Date
    var objectID: String
}

struct PUTStudentLocationResponseJSON: Decodable {
    var vupdatedAt: Date
}


