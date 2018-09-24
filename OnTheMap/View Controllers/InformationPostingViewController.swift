//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/23/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {

    @IBOutlet weak var geoSearchTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var debuggingTextField: UITextField!
    
    
    // Data model objects
    let locationManager = CLLocationManager()
    var mapClient: MapClient!
    var region: MKCoordinateRegion? = nil
    
    // Parameters to bundle into Segue for pin posting
    var centralCoordinate: CLLocationCoordinate2D? = nil
    var urlToBundle: String? = nil
    var mapStringToBundle: String? = nil

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the mapClient
        mapClient = MapClient.sharedInstance()
        urlTextField.text = MapClient.DummyUserData.MediaURLValue
    }
    
    @IBAction func findLocation(_ sender: Any) {
        if geoSearchTextField.text == "" {
            displayTextOnUI("Please enter a location to search.")
        } else {
            
            performUIUpdatesOnMain {
                self.activityIndicator.startAnimating()
                self.displayTextOnUI("Searching for a location match...")
            }
            
            let queryText = geoSearchTextField.text
            let queryRegion = region ?? MapClient.sharedInstance().defaultRegion!
            
            mapClient.getCoordinatesFromStringQuery(queryString: queryText!, region: queryRegion) { (success, returnedCoordinate, errorString) in
                
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                }
                
                performUIUpdatesOnMain {
                    if success! {
                        var successMessage = "** Success! "
                        successMessage += "Map point matched at \(returnedCoordinate!.latitude) latitude and \(returnedCoordinate!.longitude) longitude."
                        print(successMessage)
                        self.ConfirmLocation(returnedCoordinate!)
                    } else {
                        self.displayTextOnUI(errorString!)
                    }
                }
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Confirm Location Function
    func ConfirmLocation(_ mapPointToCheck: CLLocationCoordinate2D) {
        centralCoordinate = mapPointToCheck
        urlToBundle = urlTextField.text
        
        
        performSegue(withIdentifier: "ConfirmLocation", sender: self)
    }
    
    
    func displayTextOnUI(_ displayString: String) {
        debuggingTextField.alpha = 1.0
        debuggingTextField.text = displayString
        //fadeOutTextField(errorTextfield)
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmLocation" {
            let mapConfirmationVC = segue.destination as? MapConfirmationViewController
            mapConfirmationVC?.centralCoordinate = centralCoordinate
        }
    }

}
