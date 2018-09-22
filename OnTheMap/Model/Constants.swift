//
//  Constants.swift
//  OnTheMap
//
//  Created by Erich Clark on 8/30/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import MapKit

extension MapClient {
    
    struct Constants {
        static let DefaultMapZoom = CLLocationDistance(50000) // Max allowed, 50 km
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
        static let ValidLatitudeRange = (-90.000...90.000)
        static let ValidLongitudeRange = (-180.000...180.000)
    }
    
    // Addresses
    struct Addresses {
        static let UdacityAPIAddress = "https://www.udacity.com/api/session"
        static let ParseServerAddress = "https://parse.udacity.com/parse/classes/StudentLocation?limit=1000"
    }
    
    struct Headers {
        static let ParseApplicationIDKey = "X-Parse-Application-Id"
        static let ParseApplicationIDValue = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey = "X-Parse-REST-API-Key"
        static let RestAPIKeyValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let CharSetHeaderFields = [
            "content-type": "application/json",
            "accept": "application/json"]
    }
    
    struct DummyUserData {
        static let FirstNameValue = "Waldo"
        static let LastNameValue = "Martin"
        static let MediaURLValue = "https://en.wikipedia.org/wiki/Where%27s_Wally%3F"
    }
    
    // MARK: Methods
    struct OptionalParameters {
        static let Limit = "limit=" // use with Int
        static let Skip = "skip=" // use with Int
        static let ReverseOrder = "-"
    }
    
}
