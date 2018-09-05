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
        mapClient.loginToUdacity(username: self.emailField.text!, password: self.passwordField.text!) { (success, sessionID, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.loadStudentLocations()
                } else {
                    self.displayError(errorString!)
                }
            }
        }
        //performSegue(withIdentifier: "loginComplete", sender: AnyObject.self)
    }
    
    func loadStudentLocations() {
        print("TODO- implement load student lGocations.")
        //mapClient.getAllStudentLocations()
    }
    
    func displayError(_ errorString: String) {
        print(errorString)
    }
}

