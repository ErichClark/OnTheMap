//
//  MapClient.swift
//  OnTheMap
//
//  Created by Erich Clark on 8/31/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

// MARK: - MapClient: NSObject

class MapClient: NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    var allStudents: [VerifiedStudentPin]? = nil
    var sessionID: String? = nil
    var accountKey: String? = nil
    var currentLocation: CLLocationCoordinate2D? = nil
    var userObjectId: String? = nil
    var defaultRegion: MKCoordinateRegion? = nil
    
    // MARK: GET Method
    func taskForGETMethod<T: Decodable>(_ address: String, optionalQueries: [String:String]?, completionHandlerForGET: @escaping (_ result: T?, _ errorString: String?) -> Void) {
        
        var errorInGETRequest: String? = nil
        
        let url = MapClient.URLFromParameters(address: address, optionalQueries: optionalQueries)
        var urlRequest = URLRequest(url:url)
        
        urlRequest.allHTTPHeaderFields = Headers.CharSetHeaderFields
        urlRequest.addValue(Headers.RestAPIKeyValue, forHTTPHeaderField: Headers.RestApiKey)
        urlRequest.addValue(Headers.ParseApplicationIDValue, forHTTPHeaderField: Headers.ParseApplicationIDKey)
        
        urlRequest.httpMethod = "GET"
        
        // Verbose printing
        // print("** URL for GET request = \(urlRequest)")
        
        // Make the request
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, httpURLResponse, error) in
            
            errorInGETRequest = CheckForNetworkError(data: data, httpURLResponse: httpURLResponse as? HTTPURLResponse, error: error)
            if errorInGETRequest != nil {
                completionHandlerForGET(nil, errorInGETRequest)
            }
            
            var jsonObject: T? = nil
            do {
                // Verbose data printing
                // print("** Attempting to parse \(T.self) with size: \(String(describing: data?.count))")
                // print(String(data: data!, encoding: .utf8)!)
                let jsonDecoder = JSONDecoder()
                let jsonData = Data(data!)
                jsonObject = try jsonDecoder.decode(T.self, from: jsonData)
                completionHandlerForGET(jsonObject, nil)
            } catch {
                errorInGETRequest = "** Could not parse data response from GET request \(jsonObject.debugDescription)"
                completionHandlerForGET(jsonObject, errorInGETRequest)
            }
        }
        task.resume()
    } // End of taskForGETMethod
    
    // MARK: - POST Method
    func taskForPOSTOrPUTMethod<TRequest: Encodable>(_ address: String, optionalQueries: [String:String], postObject: TRequest, requestType: String, completionHandlerForPOST: @escaping (_ result: Data?, _ errorString: String?) -> Void ) {
        
        var errorInPOSTRequest: String? = nil
        
        let url = MapClient.URLFromParameters(address: address, optionalQueries: optionalQueries)
        var urlRequest = URLRequest(url: url)
        
        urlRequest.allHTTPHeaderFields = Headers.CharSetHeaderFields
        urlRequest.addValue(Headers.RestAPIKeyValue, forHTTPHeaderField: Headers.RestApiKey)
        urlRequest.addValue(Headers.ParseApplicationIDValue, forHTTPHeaderField: Headers.ParseApplicationIDKey)
        
        // Verbose data printing
        // print("** URL \(requestType) request = \(urlRequest)")
        
        var postBody: Data? = nil
        do {
            let jsonEncoder = JSONEncoder()
            postBody = try jsonEncoder.encode(postObject)
            // Verbose printing
            // print("** postBody = \(String(describing: postBody))")
            // print(String(data: postBody!, encoding: .utf8)!)
        }
        catch{
            errorInPOSTRequest = "Json POST encoding error - \(error)"
            completionHandlerForPOST(nil, errorInPOSTRequest)
        }
        
        urlRequest.httpMethod = requestType
        urlRequest.httpBody = postBody
        
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, httpURLResponse, error) in
            
            errorInPOSTRequest = CheckForNetworkError(data: data, httpURLResponse: httpURLResponse as? HTTPURLResponse, error: error)
            if errorInPOSTRequest != nil {
                completionHandlerForPOST(nil, errorInPOSTRequest)
            }
            
            if error != nil {
                errorInPOSTRequest = "\(String(describing: error)) - \(String(describing: httpURLResponse))"
                completionHandlerForPOST(nil, errorInPOSTRequest)
            } else {
                completionHandlerForPOST(data, nil)
            }
            
            
        }
        task.resume()
    } // End of taskForPOSTMethod
    
    // MARK: - Task for DELETE
    func taskForDELETEMethod(_ cookie: HTTPCookie, completionHandlerForDELETE: @escaping (_ result: Data?, _ errorString: String?) -> Void) {
        
        var errorInDELETERequest: String? = nil
        
        let urlAddress = MapClient.Addresses.UdacityAPIAddress
        let url = MapClient.URLFromParameters(address: urlAddress, optionalQueries: nil)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue(cookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        
        // Verbose data printing
        // print("** URL for DELETE method = \(urlRequest)")
        
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, httpURLResponse, error) in
            
            errorInDELETERequest = CheckForNetworkError(data: data, httpURLResponse: httpURLResponse as? HTTPURLResponse, error: error)
            if errorInDELETERequest != nil {
                completionHandlerForDELETE(nil, errorInDELETERequest)
            }
            
            if error != nil {
                errorInDELETERequest = "** DELETE request error - \(String(describing: error)) - \(String(describing: httpURLResponse))"
                completionHandlerForDELETE(nil, errorInDELETERequest)
            } else {
                completionHandlerForDELETE(data, nil)
            }
        }
        task.resume()
    }
    
    // MARK: - Build URL from parameters
    class func URLFromParameters(address: String, optionalQueries: [String:String]?) -> URL {
        var components = URLComponents(string: address)
        
        if optionalQueries != nil {
            var queryItems = [URLQueryItem]()
            for (key, value) in optionalQueries! {
                queryItems.append( URLQueryItem(name: key, value: "\(value)"))
            }
            components?.queryItems = queryItems
        }
        // Verbose Components printing
        // print(components.string!)
        return (components?.url!)!
    }
    
    class func parseUdacityError(data: Data) -> String {
        var returnString: String = ""
        do {
            let jsonDecoder = JSONDecoder()
            let jsonData = Data(data)
            let errorObject = try jsonDecoder.decode(UdacityError.self, from: jsonData)
            returnString = "** Error \(String(describing: errorObject.status)): \(String(describing: errorObject.error))"
        }
        catch {print(error)}
        return returnString
    }
    
    // MARK: Shared Instance Singleton
    class func sharedInstance() -> MapClient {
        struct Singleton {
            static var sharedInstance = MapClient()
        }
        return Singleton.sharedInstance
    }
}
