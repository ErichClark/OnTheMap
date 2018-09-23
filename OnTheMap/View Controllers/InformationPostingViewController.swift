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
    
    // Data model objects
    let locationManager = CLLocationManager()
    var mapClient: MapClient!
    var centralCoordinate: CLLocationCoordinate2D? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the mapClient
        mapClient = MapClient.sharedInstance()
    }
    
    @IBAction func findLocation(_ sender: Any) {
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lookUpCoordinates" {
            let mapVC = segue.destination as? MapViewController
            mapVC?.centralCoordinate = centralCoordinate
        }
    }

}
