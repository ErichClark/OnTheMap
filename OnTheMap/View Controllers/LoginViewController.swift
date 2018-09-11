//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Erich Clark on 8/30/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var errorTextfield: UITextField!
    
    var mapClient: MapClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the Map client
        mapClient = MapClient.sharedInstance()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Actions
    @IBAction func loginButton(_ sender: Any) {
        mapClient.loginToUdacity(username: self.emailField.text!, password: self.passwordField.text!) {
            (success, sessionID, errorString) in

            performUIUpdatesOnMain {
                if success {
                    self.loadStudentLocations()
                } else {
                    self.displayTextOnUI(errorString!)
                }
            }
        }
        //performSegue(withIdentifier: "loginComplete", sender: AnyObject.self)
        //temporarySessionMethod()
    }
    
    func loadStudentLocations() {
        displayTextOnUI("Getting student locations...")
//        temporaryGetStudentLocations()
        mapClient.getAllValidStudentLocations() {
            (success, allValidStudentLocations, errorString) in

            performUIUpdatesOnMain {
                if success {
                    var successMessage = "Success! "
                    successMessage += "\(String(describing: allValidStudentLocations!.count)) students returned."
                    self.displayTextOnUI(successMessage)
                } else {
                    self.displayTextOnUI(errorString!)
                }
            }
        }
    }
    
    func displayTextOnUI(_ displayString: String) {
        errorTextfield.text = displayString
    }
    
    func temporaryGetStudentLocations() {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        print("** URL request for temp student locations = \(String(describing: request.url))")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            //print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()
    }
}

