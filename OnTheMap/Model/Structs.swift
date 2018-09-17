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

// Student objects that have been cleaned
struct VerifiedStudent {
    var objectId: String// auto-generated id/key by Parse, uniquely identifies StudentLocation
    var uniqueKey: String
    var firstName: String
    var lastName: String //= Constants.Keys.LastName
    var mapString: String// plain text for geocoding student location-
    var mediaURL: String //= Constants.Keys.MediaURL // URL provided by the student
    var latitude: Double // (ranges from -90 to 90)
    var longitude: Double // (ranges from -180 to 180)
    var createdAt: String // When location was created
    var updatedAt: String?
}

// These next two are junk structs.
// Everything is optional, because Udacity Parse server response JSONs are extremely low quality and cause Decodable to fail.
// (Measured on Sept. 12, 2018: only 8.3% was usable, non-repeated data.)
// These structs must accept the same low quality of data as Udacity, utilizing the decodeIfPresent protocol to succeed even if keys are missing and accept any value provided for a given key.
struct AllStudentLocations: Decodable {
    var results: [StudentLocation]?
}

class StudentLocation: Decodable {
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: String?
    var updatedAt: String?
    
    enum UserResponseKeys: String, CodingKey {
        case objectId = "objectId"
        case uniqueKey = "uniqueKey"
        case firstName = "firstName"
        case lastName = "lastName"
        case mapString = "mapString"
        case mediaURL = "mediaURL"
        case latitude = "latitude"
        case longitude = "longitude"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserResponseKeys.self)
    
        self.objectId = try container.decodeIfPresent(String.self, forKey: .objectId)
        self.uniqueKey = try container.decodeIfPresent(String.self, forKey: .uniqueKey)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.mapString = try container.decodeIfPresent(String.self, forKey: .mapString)
        self.mediaURL = try container.decodeIfPresent(String.self, forKey: .mediaURL)
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}

func getCoordinate(latitude: Double, longitude: Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
    }

// TODO: -
//func getMapItem(student: StudentLocation) -> MKMapItem {
//        let addressDict = [CNPostalAddressCityKey: student.mapString!]
//    let coordinate = getCoordinate(latitude: student.latitude!, longitude: student.longitude!)
//
    //let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: student.addressDict)
//        let mapItem = MKMapItem(placemark: placemark)
//        mapItem.name = student.firstName! + " " + student.lastName!
//        return mapItem
//    }
//}

struct POSTorPUTStudentLocationJSON: Encodable {
    let uniqueKey: String = MapClient.sharedInstance().accountKey! // Recommended as Udacity acc ID
    let firstName: String = MapClient.DummyUserData.FirstNameValue
    let lastName: String  = MapClient.DummyUserData.LastNameValue
    let mediaURL:String = MapClient.DummyUserData.MediaURLValue // URL provided by the student
    
    let mapString: String // plain text for geocoding student location- "Mountain View, CA"
    let latitude: Double // (ranges from -90 to 90)
    let longitude: Double // (ranges from -180 to 180)
    // TODO: - Can a POST request be made if the objectId=nil value is sent?
    // The only difference between PUT and POST is this key:value
    let objectId: String? // For PUT auto-generated id/key by Parse, uniquely identifies StudentLocation
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
    var objectId: String
}

struct PUTStudentLocationResponseJSON: Decodable {
    var vupdatedAt: Date
}

struct UdacityError: Decodable {
    var status: Int
    var error: String
}
