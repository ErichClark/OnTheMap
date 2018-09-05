//
//  Constants.swift
//  OnTheMap
//
//  Created by Erich Clark on 8/30/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation

extension MapClient {
    
    struct Constants {
        static let Parse_Application_ID_Value = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let REST_API_Key_Value = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let UdacityIDValue = "????"
        static let FirstNameValue = "Waldo"
        static let LastNameValue = "Martin"
        static let MediaURLValue = "www.qalang.com"
        
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let AuthorizationPath = "/api/session"
        static let StudentQueryPath = "/classes/StudentLocation"
        static let AccountURL = ""
        static let HeaderFields = [
            "content-type": "application/json;charset=utf-8",
            "accept": "application/json;charset=utf-8"]
        static let DefaultMapZoom = 1000
    }
    
    // MARK: Methods
    struct Methods {
        static let POSTUdacityForSession = "/api/session"
        static let AllStudents = "https://parse.udacity.com/parse/classes/StudentLocation"
        static let Limit = "limit=" // use with Int
        static let Skip = "skip=" // use with Int
        
    }
    
    // MARK: parameter keys
    struct ParameterKeys {
        static let ParseApplicationIDKey = "Parse_Application_ID"
        static let RestApiKey = "REST_API_Key"
        static let ReverseOrder = "-"
    }
    
    
    //[REST_API_Key=QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY, Parse_Application_ID=QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr]
    
}
