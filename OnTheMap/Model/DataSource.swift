//
//  DataSource.swift
//  OnTheMap
//
//  Created by Erich Clark on 10/17/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation

class DataSource: NSObject {
    var allStudents: [VerifiedStudentPin]? = nil

    
    
    // MARK: Shared Instance Singleton
    class func sharedInstance() -> DataSource {
        struct Singleton {
            static var sharedInstance = DataSource()
        }
        return Singleton.sharedInstance
    }
}
