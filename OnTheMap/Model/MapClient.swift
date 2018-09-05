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
    
    func taskForGETMethod<T: Decodable>(_ method: String, parameters: [String:String], completionHandlerForGET: @escaping (_ result: T?, _ error: String?) -> Void) {
        
        var errorInGETRequest: String? = nil
        // Set the parameters
        var parametersWithAPIKey = parameters
        parametersWithAPIKey[ParameterKeys.RestApiKey] = Constants.REST_API_Key_Value
        parametersWithAPIKey[ParameterKeys.ParseApplicationIDKey] = Constants.Parse_Application_ID_Value
        
        // Build URL from parameters (uses helper method below)
        let url = MapClient.URLFromParameters(parametersWithAPIKey, withPathExtension: method)
        let urlRequest = URLRequest(url:url)
        print("** URL Request for \(method) = \(urlRequest)")
        
        // Make the request
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, httpURLResponse, error) in
            
            errorInGETRequest = CheckForNetworkError(data: data, httpURLResponse: httpURLResponse as? HTTPURLResponse, error: error)
            
            var jsonObject: T? = nil
            do {
                let jsonDecoder = JSONDecoder()
                let jsonData = Data(data!)
                jsonObject = try jsonDecoder.decode(T.self, from: jsonData)
            } catch {
                errorInGETRequest = "** Could not parse data response from GET request"
                return
            }
            
            completionHandlerForGET(jsonObject, errorInGETRequest)
        }
        
        task.resume()
    }
    
    // MARK: - taskForPOSTMethod
    func taskForPOSTMethod<TResponse: Decodable, TRequest: Encodable>(_ method: String, parameters: [String:String], postObject: TRequest, completionHandlerForPOST: @escaping (_ result: TResponse?, _ nsError: String?) -> Void ) {
        
        var errorInPOSTRequest: String? = nil
        let headerFields = Constants.HeaderFields
        
        var parametersWithApiKey = parameters
        parametersWithApiKey[ParameterKeys.RestApiKey] = Constants.REST_API_Key_Value
        parametersWithApiKey[ParameterKeys.ParseApplicationIDKey] = Constants.Parse_Application_ID_Value
        
        let url = MapClient.URLFromParameters(parametersWithApiKey, withPathExtension: method)
        var urlRequest = URLRequest(url: url)
        print("** URL request for \(method) = \(urlRequest)")
        
        var postBody: Data? = nil
        do {
            let jsonEncoder = JSONEncoder()
            postBody = try jsonEncoder.encode(postObject)
            print("** postBody = ")
            print(String(data: postBody!, encoding: .utf8)!)
        }
        catch{print(error)}
        
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = headerFields
        urlRequest.httpBody = postBody
        
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, httpURLResponse, error) in
            
            errorInPOSTRequest = CheckForNetworkError(data: data, httpURLResponse: httpURLResponse as? HTTPURLResponse, error: error)
            print("**task started -")
            
            var dataToParse = data!
            // Remove Udacity security characters
            if method == MapClient.Methods.POSTUdacityForSession {
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range)
                dataToParse = newData!
            }
            print("** dataToParse = ")
            print(String(data: dataToParse, encoding: .utf8)!)
            var jsonObject: TResponse? = nil
            do {
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
    class func URLFromParameters(_ parameters: [String:String], withPathExtension: String?) -> URL {
        //print("parameters = \(parameters)")
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = withPathExtension ?? ""
        //print("components = \(components)" )
        components.queryItems = [URLQueryItem]()
        if parameters.count > 0 {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        //print(components.string!)
        return components.url!
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
