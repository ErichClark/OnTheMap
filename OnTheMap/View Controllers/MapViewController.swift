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
        // TODO: - Use Safe Area Inset?
        super.viewDidLoad()
        
        // get the Map client
        mapClient = MapClient.sharedInstance()
        mapView.delegate = self
        allStudents = mapClient.allStudents
        
        centerMap()
        
        mapView.addAnnotations(allStudents!)
        
        // Center view on a 500 kilometer radius of a student pin from TableTab ViewController, if provided
        //let initialLocation = CLLocation(latitude: centralStudentPin.latitude!, longitude: centralStudentPin.longitude!)
        // Do any additional setup after loading the view.
        //centerOnMapLocation(location: initialLocation)
        
        // Set the mapview delegate
        mapView.delegate = self
        mapView.register(PinAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    
    // MARK: -Check for Location when in use permissions
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // Map centering helper
    func centerMap() {
//        if centralCoordinate == nil {
//            let locationHelper = GetLocationHelper()
//            locationHelper.returnOneLocation() {
//                (currentLocation, errorString) in
//
//                if errorString != nil {
//                    self.displayTextOnUI(errorString!)
//                }
//                self.centralCoordinate = currentLocation
//            }
//        } else {
//
//        }
        if centralCoordinate != nil {
            let coordinateRegion = MKCoordinateRegion.init(center: centralCoordinate!, latitudinalMeters: MapClient.Constants.DefaultMapZoom, longitudinalMeters: MapClient.Constants.DefaultMapZoom)
            mapView.setRegion(coordinateRegion, animated: true)
        }
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
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        let url = pin.url
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: {(success) in print("Open \(url) \(success)")})
        }
        print("The url is \(pin.url)")
    }
}
