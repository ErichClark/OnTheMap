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
        mapClient.getAllStudentLocations() {
            (success, AllStudentLocations, errorString) in
            
            performUIUpdatesOnMain {
                if success {
                    self.displayTextOnUI("List of Student Locations loaded!")
                } else {
                    self.displayTextOnUI(errorString)
                }
            }
        }
    }
    
    func displayTextOnUI(_ displayString: String) {
        errorTextfield.text = displayString
    }
    
}

