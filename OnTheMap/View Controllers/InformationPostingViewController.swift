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
    var centralCoordinate: CLLocationCoordinate2D? = nil
    var region: MKCoordinateRegion? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the mapClient
        mapClient = MapClient.sharedInstance()

    }
    
    @IBAction func findLocation(_ sender: Any) {
        if geoSearchTextField.text == "" {
            displayTextOnUI("Please enter a location to search.")
        } else {
            
            let queryText = geoSearchTextField.text
            let queryRegion = region ?? MapClient.sharedInstance().defaultRegion!
            
            MapClient.sharedInstance().getCoordinatesFromStringQuery(queryString: queryText!, region: queryRegion) { (success, mapPoint, errorString) in
                
                
                
                
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Confirm Location Function
    func ConfirmLocation() {
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
            let mapVC = segue.destination as? MapViewController
            mapVC?.centralCoordinate = centralCoordinate
        }
    }

}
