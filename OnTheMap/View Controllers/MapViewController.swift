//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/4/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // Data Model objects
    var allStudents: [VerifiedStudentPin]? = nil
    var centralCoordinate: CLLocationCoordinate2D? = nil
    
    // Location and map
    let locationManager = CLLocationManager()
    var mapClient: MapClient!
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // Loading and status update outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingTextField: UITextField!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the Map client
        mapClient = MapClient.sharedInstance()
        mapView.delegate = self
        allStudents = mapClient.allStudents
        
        mapView.addAnnotations(allStudents!)
        
        // Set the mapview delegate
        mapView.delegate = self
        mapView.register(PinAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        centerMap()
    }
    // MARK: - Check for Location when in use permissions
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // Map centering helper
    func centerMap() {
        // MARK: - Center initial map and set default region
        var region: MKCoordinateRegion? = nil
        if centralCoordinate == nil {
            region = MKCoordinateRegion.init(center: MapClient.Constants.DefaultMapCenterUSA, latitudinalMeters: MapClient.Constants.DefaultMapZoom, longitudinalMeters: MapClient.Constants.DefaultMapZoom)
        } else if centralCoordinate != nil {
            region = MKCoordinateRegion.init(center: centralCoordinate!, latitudinalMeters: MapClient.Constants.DefaultMapZoom, longitudinalMeters: MapClient.Constants.DefaultMapZoom)
        }
        mapView.setRegion(region!, animated: true)
        MapClient.sharedInstance().defaultRegion = region
    }

    // Debugger Textfield display
    
    
    // MARK: - Actions
    
    @IBAction func reload(_ sender: Any) {
        performUIUpdatesOnMain {
            
            self.activityIndicator.startAnimating()
        }
        
        print("Getting student locations...")
        //        temporaryGetStudentLocations()
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
                    self.activityIndicator.stopAnimating()
                } else {
                    self.displayTextOnUI(errorString!)
                    self.activityIndicator.stopAnimating()
                    print(errorString!)
                }
            }
        }
    
    }
    
    func displayTextOnUI(_ displayString: String) {
        loadingTextField.text = displayString
        //loadingTextField.alpha = 1.0
        //fadeOutTextField(loadingTextField)
    }
    
    @IBAction func addPin(_ sender: Any) {
        performSegue(withIdentifier: "addPin", sender: self)
    }
    
    @IBAction func logOut(_ sender: Any) {
        performUIUpdatesOnMain {
            self.activityIndicator.startAnimating()
        }
        
        displayTextOnUI("Logging out of Udacity...")
        mapClient.logOutOfUdacity() { (success, successMessage, errorMessage) in
            
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
            performUIUpdatesOnMain {
                if success {
                    print(successMessage!)
                } else {
                    print(errorMessage!)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard  let annotation = annotation as? VerifiedStudentPin else {
            return nil
        }
        
        let identifier = "student"
        var view: PinAnnotationView
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PinAnnotationView {
            dequedView.annotation = annotation
            view = dequedView
        } else {
            view = PinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .custom)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let pin = view.annotation as! VerifiedStudentPin
        let url = URL(fileURLWithPath: String(pin.mediaURL))
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: {(success) in print("Open \(url) \(success)")})
        }
        print("The url is \(pin.mediaURL)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPin" {
            let infoPostingVC = segue.destination as! InformationPostingViewController
            infoPostingVC.region = mapView.region
        }
    }
}
