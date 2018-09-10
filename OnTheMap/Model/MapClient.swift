//
//  MapClient.swift
//  OnTheMap
//
//  Created by Erich Clark on 8/31/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation

// MARK: - MapClient: NSObject

class MapClient: NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    var allStudents: AllStudentLocations? = nil
    var sessionID: String? = nil
    var accountKey: String? = nil
    // Config?
    //
    
    // authentication states?
    //
    
    // MARK: GET
    
    func taskForGETMethod<T: Decodable>(_ address: String, optionalQueries: [String:String]?, completionHandlerForGET: @escaping (_ result: T?, _ errorString: String?) -> Void) {
        
        var errorInGETRequest: String? = nil
        
        let url = MapClient.URLFromParameters(address: address, optionalQueries: optionalQueries)
        var urlRequest = URLRequest(url:url)
        
        urlRequest.allHTTPHeaderFields = Headers.CharSetHeaderFields
        urlRequest.addValue(Headers.RestAPIKeyValue, forHTTPHeaderField: Headers.RestApiKey)
        urlRequest.addValue(Headers.ParseApplicationIDValue, forHTTPHeaderField: Headers.ParseApplicationIDKey)
        
        urlRequest.httpMethod = "GET"
        
        print("** URL Request for \(address) = \(urlRequest)")
        
        // Make the request
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, httpURLResponse, error) in
            
            errorInGETRequest = CheckForNetworkError(data: data, httpURLResponse: httpURLResponse as? HTTPURLResponse, error: error)
            
//            var dataToParse = data!
//            let range = Range(5..<data!.count)
//            let newData = data?.subdata(in: range)
//            dataToParse = newData!
            
            var jsonObject: T? = nil
            do {
                print("** MapClient is attempting to parse the following as a \(T.self) :")
                print(String(data: data!, encoding: .utf8)!)
                let jsonDecoder = JSONDecoder()
                let jsonData = Data(data!)
                jsonObject = try jsonDecoder.decode(T.self, from: jsonData)
                print(jsonObject.debugDescription)
                completionHandlerForGET(jsonObject, nil)
            } catch {
                errorInGETRequest = "** Could not parse data response from GET request \(jsonObject.debugDescription)"
                completionHandlerForGET(jsonObject, errorInGETRequest)
            }
        }
        
        task.resume()
    }
    
    // MARK: - taskForPOSTMethod
    func taskForPOSTMethod<TResponse: Decodable, TRequest: Encodable>(_ address: String, optionalQueries: [String:String], postObject: TRequest, completionHandlerForPOST: @escaping (_ result: TResponse?, _ nsError: String?) -> Void ) {
        
        var errorInPOSTRequest: String? = nil
        
        let url = MapClient.URLFromParameters(address: address, optionalQueries: optionalQueries)
        var urlRequest = URLRequest(url: url)
        
        urlRequest.allHTTPHeaderFields = Headers.CharSetHeaderFields
        urlRequest.addValue(Headers.RestAPIKeyValue, forHTTPHeaderField: Headers.RestApiKey)
        urlRequest.addValue(Headers.ParseApplicationIDValue, forHTTPHeaderField: Headers.ParseApplicationIDKey)
        
        print("** URL request for \(address) = \(urlRequest)")
        
        var postBody: Data? = nil
        do {
            let jsonEncoder = JSONEncoder()
            postBody = try jsonEncoder.encode(postObject)
            print("** postBody = ")
            print(String(data: postBody!, encoding: .utf8)!)
        }
        catch{print(error)}
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postBody
        
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, httpURLResponse, error) in
            
            errorInPOSTRequest = CheckForNetworkError(data: data, httpURLResponse: httpURLResponse as? HTTPURLResponse, error: error)
            print("**task started -")
            
            var dataToParse = data!
            // Remove Udacity security characters
            if address == MapClient.Addresses.UdacityAPIAddress {
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range)
                dataToParse = newData!
            }
            
//            print("** dataToParse = ")
//            print(String(data: dataToParse, encoding: .utf8)!)
            
            var jsonObject: TResponse? = nil
            do {
                print("** MapClient is attempting to parse the following as a \(TResponse.self) :")
                print(String(data: data!, encoding: .utf8)!)
                let jsonDecoder = JSONDecoder()
                let jsonData = Data(dataToParse)
                jsonObject = try jsonDecoder.decode(TResponse.self, from: jsonData)
                completionHandlerForPOST(jsonObject, nil)
            } catch {
                errorInPOSTRequest = "** Could not parse JSON as \(TResponse.self)"
                errorInPOSTRequest = MapClient.parseUdacityError(data: dataToParse)
                completionHandlerForPOST(nil, errorInPOSTRequest)
            }
            
            //completionHandlerForPOST(jsonObject, errorInPOSTRequest)
        }
        
        task.resume()
    }
    
    
    
    // Build URL from parameters
    class func URLFromParameters(address: String, optionalQueries: [String:String]?) -> URL {
        var components = URLComponents(string: address)
        
        if optionalQueries != nil {
            var queryItems = [URLQueryItem]()
            for (key, value) in optionalQueries! {
                queryItems.append( URLQueryItem(name: key, value: "\(value)"))
            }
            components?.queryItems = queryItems
        }
        //print(components.string!)
        return (components?.url!)!
    }
    
    class func parseUdacityError(data: Data) -> String {
        var returnString: String = ""
        do {
            let jsonDecoder = JSONDecoder()
            let jsonData = Data(data)
            let errorObject = try jsonDecoder.decode(UdacityError.self, from: jsonData)
            returnString = "Error \(errorObject.status): \(errorObject.error)"
        }
        catch { returnString = error as! String }
        return returnString
    }
    // MARK: Shared Instance
    
    class func sharedInstance() -> MapClient {
        struct Singleton {
            static var sharedInstance = MapClient()
        }
        return Singleton.sharedInstance
    }
}
