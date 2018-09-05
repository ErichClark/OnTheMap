//
//  Structs.swift
//  OnTheMap
//
//  Created by Erich Clark on 8/30/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import MapKit
import Contacts

struct AllStudentLocations: Decodable {
    var results: [StudentLocation]?
}

class StudentLocation: NSObject, Decodable {
    
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
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressCityKey: mapString!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = firstName! + " " + lastName!
        return mapItem
    }
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

struct SessionPOSTBody: Encodable {
    let udacity: Udacity
}

struct Udacity: Encodable {
    let username: String
    let password: String
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
    var key: String
}

struct Session: Decodable {
    var id: String
    var expiration: String
}

struct POSTStudentLocationResponseJSON: Decodable {
    var createdAt: Date
    var objectID: String
}

struct PUTStudentLocationResponseJSON: Decodable {
    var vupdatedAt: Date
}

struct UdacityError: Decodable {
    var status: Int
    var error: String
}
