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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var mapClient: MapClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the Map client
        mapClient = MapClient.sharedInstance()        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        displayTextOnUI("")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    @IBAction func loginButton(_ sender: Any) {
        if (emailField.text?.isEmpty)! {
            self.displayTextOnUI("Please enter an email address.")
        } else if (passwordField.text?.isEmpty)! {
            self.displayTextOnUI("Please enter your password.")
        } else {
            
            performUIUpdatesOnMain {
                self.activityIndicator.startAnimating()
            }
            
            // MARK: - Login Convenience method with stored user/pswd
            // For safe convenience while debugging, an untracked PrivateConstants file is kept locally on my development computer.
            mapClient.loginToUdacity(username: PrivateConstants.username, password: PrivateConstants.password) {
                (success, sessionID, errorString) in
            
            // MARK: Standard login method
            // For a distributed build, the following code should be used instead:
            // mapClient.loginToUdacity(username: self.emailField.text!, password: self.passwordField.text!) {
            // (success, sessionID, errorString) in
            
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                }
                
                performUIUpdatesOnMain {
                    if success {
                        self.loadStudentLocations()
                    } else {
                        self.displayTextOnUI(errorString!)
                    }
                }
            }
        }
    }
    
    func loadStudentLocations() {
        
        performUIUpdatesOnMain {
            self.activityIndicator.startAnimating()
        }
        
        displayTextOnUI("Getting student locations...")
        mapClient.get100ValidStudentLocations() {
            (success, allValidStudentLocations, errorString) in

            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
            
            performUIUpdatesOnMain {
                if success {
                    var successMessage = "Success! "
                    successMessage += "\(String(describing: allValidStudentLocations!.count)) students returned."
                    self.displayTextOnUI(successMessage)
                    self.performSegue(withIdentifier: "loginComplete", sender: self)
                } else {
                    self.displayTextOnUI(errorString!)
                }
            }
        }
    }
    
    func displayTextOnUI(_ displayString: String) {
        errorTextfield.text = displayString
        //fadeOutTextField(errorTextfield)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginComplete" {
            print("Login Complete")
        }
    }
}

