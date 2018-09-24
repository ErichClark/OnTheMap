//
//  MapConfirmationViewController.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/23/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import UIKit
import MapKit

class MapConfirmationViewController: UIViewController {

    var url: String? = nil
    var mapString: String? = nil
    var centralCoordinate: CLLocationCoordinate2D? = nil
    var mapClient: MapClient!
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var debuggingTextField: UITextField!
    // Loading and Status Update Outlets
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapClient = MapClient.sharedInstance()
        mapView.delegate = self
        
        centerMap()
    }
    
    func centerMap() {
        if centralCoordinate != nil {
            let coordinateRegion = MKCoordinateRegion.init(center: centralCoordinate!, latitudinalMeters: MapClient.Constants.DefaultMapZoom, longitudinalMeters: MapClient.Constants.DefaultMapZoom)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }

    func displayTextOnUI(_ displayString: String) {
        debuggingTextField.text = displayString
        //fadeOutTextField(debuggingTextField)
    }
    
    // MARK: - Actions
    @IBAction func confirmMapLocation(_ sender: Any) {
        
        performUIUpdatesOnMain {
            self.activityIndicator.startAnimating()
        }
        
        displayTextOnUI("Posting your location to Udacity...")
        mapClient.postStudentLocation(mediaURL: url ?? MapClient.DummyUserData.MediaURLValue, mapString: mapString!, latitude: (centralCoordinate?.latitude)!, longitude: (centralCoordinate?.longitude)!) { (success, response, errorString) in
            
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
            
            performUIUpdatesOnMain {
                if success {
                    var successMessage = "** Success! "
                    successMessage += "Your object ID is \(String(describing: response?.objectId))"
                    self.displayTextOnUI(successMessage)
                    self.performSegue(withIdentifier: "successfulPost", sender: self)
                }
            }
            
        }
    }
    
    @IBAction func backToTextSearch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successfulPost" {
            let navVC = segue.destination as? MapViewController
            navVC?.centralCoordinate = centralCoordinate
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension MapConfirmationViewController: MKMapViewDelegate {
    
}
