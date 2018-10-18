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
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var debuggingTextField: UITextField!
    // Loading and Status Update Outlets
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapClient = MapClient.sharedInstance()
        mapView.delegate = self
        debuggingTextField.isHidden = true

        centerMap()
    }
    
    func centerMap() {
        
        let coordinate = resultForMapConfirmation?.placemark.coordinate
        let coordinateRegion = MKCoordinateRegion.init(
            center: coordinate!,
            latitudinalMeters: DataSource.Constants.DefaultMapLookupZoom,
            longitudinalMeters: DataSource.Constants.DefaultMapLookupZoom)
            mapView.setRegion(coordinateRegion, animated: true)
        
        let pin = MKPointAnnotation()
        pin.title = resultForMapConfirmation?.name
        pin.coordinate = coordinate!
        mapView.addAnnotation(pin)
        
    }

    func displayTextOnUI(_ displayString: String) {
        debuggingTextField.isHidden = false
        debuggingTextField.text = displayString
    }

    
    // MARK: - Actions

    @IBAction func confirmMapLocation(_ sender: Any) {
        performUIUpdatesOnMain {
            self.activityIndicator.startAnimating()
            self.displayTextOnUI("Posting your location to Udacity...")
        }
        
        let coordinateLat = resultForMapConfirmation?.placemark.coordinate.latitude
        let coordinateLong = resultForMapConfirmation?.placemark.coordinate.longitude
        let mapString = resultForMapConfirmation?.name
                
        // Sends information to pin posting method
        mapClient.placeStudentLocationPin(newMediaURL: urlFromSegue!, mapString: mapString!, latitude: coordinateLat!, longitude: coordinateLong!) { (success, successMessage, errorString) in
            
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.debuggingTextField.isHidden = true
            }
            
            performUIUpdatesOnMain {
                if success {
                    print(successMessage!)
                } else {
                    print(errorString!)
                }
                // Dismisses two view controllers at once to return to table or map views.
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backToTextSearch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

