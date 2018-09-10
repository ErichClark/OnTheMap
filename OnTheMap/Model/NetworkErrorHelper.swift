//
//  NetworkErrorHelper.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/1/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation

func CheckForNetworkError(data: Data?, httpURLResponse: HTTPURLResponse?, error: Error?) -> String? {
    
    var returnError: String? = nil
    /* GUARD: Was there an error? */
    guard (error == nil) else {
        returnError = "There was an error with your request: \(String(describing: error))"
        return returnError
    }
    
    /* GUARD: Did we get a successful 2XX response? */
    guard let statusCode = (httpURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        returnError = "Unable to decode JSON from non-200 response"
        return returnError
    }
    
    /* GUARD: Was there any data returned? */
    guard data != nil else {
        returnError = "No data was returned by the GET request!"
        return returnError
    }
     return nil
}

func parseErrorFromReturnedJSON(methodDescription: String?, data: Data) -> String? {
    var errorString: String? = nil
    //
    //        do {
    //            let jsonDecoder = JSONDecoder()
    //            let jsonData = Data(data)
    //            let decodedError = try jsonDecoder.decode(TMDBError.self, from: jsonData)
    //            if decodedError.status_code != nil {
    //                var message = "* An errorString was returned from parseErrorFromTMDB"
    //                message += "There was an error with your \(String(describing: methodDescription)) \n"
    //                message += "Movie Database returned an error of code \(String(describing: decodedError.status_code)) \n"
    //                message += "message reads \(String(describing: decodedError.status_message))"
    //                errorString = message
    //            }
    //        }
    //        catch {print(error)}
    return errorString
}
