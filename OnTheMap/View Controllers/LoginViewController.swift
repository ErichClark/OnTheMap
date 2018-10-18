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
        errorTextfield.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayTextOnUI("")
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
                self.resignFirstResponder()
            }
            
            // MARK: - Login Convenience method with stored user/pswd
            // For safe convenience while debugging, an untracked PrivateConstants.swift file is kept locally on my development computer. It has been removed for distribution.
//            mapClient.loginToUdacity(username: PrivateConstants.username, password: PrivateConstants.password) {
//                (success, sessionID, errorString) in
            
            // MARK: Standard login method
            // For a distributed build, the following code should be used instead:
             mapClient.loginToUdacity(username: self.emailField.text!, password: self.passwordField.text!) {
             (success, sessionID, errorString) in
            
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.errorTextfield.isHidden = true
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
    
    @IBAction func signUp(_ sender: Any) {
        // Udacity online sign up
        let url = URL(string: String(MapClient.Addresses.UdacitySignupAddress))
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: {(success) in
                print("Open \(String(describing: url)) \(success)")})
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
                    self.errorTextfield.isHidden = true
                    self.performSegue(withIdentifier: "loginComplete", sender: self)
                } else {
                    self.displayTextOnUI(errorString!)
                }
            }
        }
    }
    
    func displayTextOnUI(_ displayString: String) {
        errorTextfield.isHidden = false
        errorTextfield.text = displayString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginComplete" {
            print("Login Complete")
        }
    }
}

