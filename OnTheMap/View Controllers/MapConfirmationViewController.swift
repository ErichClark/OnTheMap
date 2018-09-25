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
    
    @IBAction func temporaryPostStudentLocation(_ sender: Any) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"objectId\": \"nil\",\"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    // MARK: - Actions
    // Decides between POST or PUT requests
    // Based on whether the user has been isssued a valid object ID
    @IBAction func confirmMapLocation(_ sender: Any) {
        if MapClient.sharedInstance().userObjectId == nil {
            POSTStudentLocation()
        } else {
            PUTStudentLocation()
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

    // MARK: - POST Location
    func POSTStudentLocation() {
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
    
    // MARK: - PUT Location
    func PUTStudentLocation() {
        performUIUpdatesOnMain {
            self.activityIndicator.startAnimating()
        }
        
        displayTextOnUI("Updating your location to Udacity...")
        
        let coordinateLat = resultForMapConfirmation?.placemark.coordinate.latitude
        let coordinateLong = resultForMapConfirmation?.placemark.coordinate.longitude
        let mapString = resultForMapConfirmation?.name
        
        // Sets a coordinate for segue to initial Map VC
        centralCoordinate = CLLocationCoordinate2D(latitude: coordinateLat!, longitude: coordinateLong!)
        
        // Sends information to pin posting method
        mapClient.putStudentLocation(mediaURL: urlFromSegue ?? MapClient.DummyUserData.MediaURLValue, mapString: mapString!, latitude: coordinateLat!, longitude: coordinateLong!) { (success, response, errorString) in
            
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
            
            performUIUpdatesOnMain {
                if success {
                    var successMessage = "** Success! "
                    successMessage += "Your location was updated at \(String(describing: response?.updatedAt))"
                    self.displayTextOnUI(successMessage)
                    self.performSegue(withIdentifier: "successfulPost", sender: self)
                }
            }
        }
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

