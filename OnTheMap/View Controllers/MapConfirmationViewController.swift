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

    var mapClient: MapClient!
    
    // Input from segue
    var resultForMapConfirmation: MKMapItem? = nil
    var urlFromSegue: String? = nil
    
    // For segue to original MapViewController
    var centralCoordinate: CLLocationCoordinate2D? = nil
    
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
        
        let coordinate = resultForMapConfirmation?.placemark.coordinate
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate!, latitudinalMeters: MapClient.Constants.DefaultMapZoom, longitudinalMeters: MapClient.Constants.DefaultMapZoom)
            mapView.setRegion(coordinateRegion, animated: true)
        
        let pin = MKPointAnnotation()
        pin.title = resultForMapConfirmation?.name
        pin.coordinate = coordinate!
        mapView.addAnnotation(pin)
        
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
        
        let coordinateLat = resultForMapConfirmation?.placemark.coordinate.latitude
        let coordinateLong = resultForMapConfirmation?.placemark.coordinate.longitude
        let mapString = resultForMapConfirmation?.name
        
        // Sets a coordinate for segue to initial Map VC
        centralCoordinate = CLLocationCoordinate2D(latitude: coordinateLat!, longitude: coordinateLong!)
        
        // Sends information to pin posting method
        mapClient.postStudentLocation(mediaURL: urlFromSegue ?? MapClient.DummyUserData.MediaURLValue, mapString: mapString!, latitude: coordinateLat!, longitude: coordinateLong!) { (success, response, errorString) in
            
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView!.canShowCallout = true

        return annotationView
    }
}
