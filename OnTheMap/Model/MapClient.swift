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

class MapClient: NSObject {
    
    // MARK: Properties
    var session = URLSession.shared
    
    // MARK: GET Method
    func taskForGETMethod<T: Decodable>(_ address: String, optionalQueries: [String:String]?, completionHandlerForGET: @escaping (_ result: T?, _ errorString: String?) -> Void) {
        
        var errorInGETRequest: String? = nil
        
        let url = MapClient.URLFromParameters(address: address, optionalQueries: optionalQueries)
        var urlRequest = URLRequest(url:url)
        
        urlRequest.allHTTPHeaderFields = DataSource.Headers.CharSetHeaderFields
        urlRequest.addValue(DataSource.Headers.RestAPIKeyValue, forHTTPHeaderField: DataSource.Headers.RestApiKey)
        urlRequest.addValue(DataSource.Headers.ParseApplicationIDValue, forHTTPHeaderField: DataSource.Headers.ParseApplicationIDKey)
        
        urlRequest.httpMethod = "GET"
        
        // Make the request
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, httpURLResponse, error) in
            
            errorInGETRequest = CheckForNetworkError(data: data, httpURLResponse: httpURLResponse as? HTTPURLResponse, error: error)
            if errorInGETRequest != nil {
                completionHandlerForGET(nil, errorInGETRequest)
            }
            
            var jsonObject: T? = nil
            do {
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
    }
    
    // MARK: - POST Method
    func taskForPOSTOrPUTMethod<TRequest: Encodable>(_ address: String, optionalQueries: [String:String], postObject: TRequest, requestType: String, completionHandlerForPOST: @escaping (_ result: Data?, _ errorString: String?) -> Void ) {
        
        var errorInPOSTRequest: String? = nil
        
        let url = MapClient.URLFromParameters(address: address, optionalQueries: optionalQueries)
        var urlRequest = URLRequest(url: url)
        
        urlRequest.allHTTPHeaderFields = DataSource.Headers.CharSetHeaderFields
        urlRequest.addValue(DataSource.Headers.RestAPIKeyValue, forHTTPHeaderField: DataSource.Headers.RestApiKey)
        urlRequest.addValue(DataSource.Headers.ParseApplicationIDValue, forHTTPHeaderField: DataSource.Headers.ParseApplicationIDKey)
        
        var postBody: Data? = nil
        do {
            let jsonEncoder = JSONEncoder()
            postBody = try jsonEncoder.encode(postObject)
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
    }
    
    // MARK: - Task for DELETE
    func taskForDELETEMethod(_ cookie: HTTPCookie, completionHandlerForDELETE: @escaping (_ result: Data?, _ errorString: String?) -> Void) {
        
        var errorInDELETERequest: String? = nil
        
        let urlAddress = DataSource.Addresses.UdacityAPIAddress
        let url = MapClient.URLFromParameters(address: urlAddress, optionalQueries: nil)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue(cookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        
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
