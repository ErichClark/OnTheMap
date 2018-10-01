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
class VerifiedStudentPin: NSObject, MKAnnotation {
    
    let name: String
    let mapString: String
    let mediaURL: String
    let coordinate: CLLocationCoordinate2D
    let uniqueKey: String?
    
    init(firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, uniqueKey: String?) {
        
        self.name = firstName + " " + lastName
        self.mediaURL = mediaURL
        self.mapString = mapString
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.uniqueKey = uniqueKey
        
        super.init()
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return mediaURL
    }
    
    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        return mapItem
    }
    
    
    
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


// Map Kit Item Generator
func getMapItem(student: VerifiedStudentPin) -> MKMapItem {
    let placemark = MKPlacemark(coordinate: student.coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = student.name
    
    let url = URL(fileURLWithPath: student.mediaURL)
    mapItem.url = url
    return mapItem
}

struct POSTOrPutStudentLocationJSON: Encodable {
    let uniqueKey: String = MapClient.sharedInstance().accountKey! // Recommended as Udacity acc ID
    let firstName: String = MapClient.DummyUserData.FirstNameValue
    let lastName: String  = MapClient.DummyUserData.LastNameValue
    var mediaURL:String = MapClient.DummyUserData.MediaURLValue // URL provided by the student
    
    let mapString: String // plain text for geocoding student location- "Mountain View, CA"
    let latitude: Double // (ranges from -90 to 90)
    let longitude: Double // (ranges from -180 to 180)
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

struct DeleteSessionResponseJSON: Decodable {
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
    var createdAt: String
    var objectId: String
}

struct PUTStudentLocationResponseJSON: Decodable {
    var updatedAt: String
}

struct UdacityError: Decodable {
    var status: Int?
    var error: String?
}
