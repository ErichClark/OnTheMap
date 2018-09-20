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
    var allStudents: [VerifiedStudent]? = nil
    let centralStudentPin: VerifiedStudent? = nil
    let defaultZoomDistance = CLLocationDistance(MapClient.Constants.DefaultMapZoom)

    // Location and map
    let locationManager = CLLocationManager()
    var mapClient: MapClient!
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lowerTabBar: UITabBarItem!
    
    // Loading and status update outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
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
        
        // Center view on a kilometer radius of a student pin from TableTab ViewController, if provided
        //let initialLocation = CLLocation(latitude: centralStudentPin.latitude!, longitude: centralStudentPin.longitude!)
        // Do any additional setup after loading the view.
        //centerOnMapLocation(location: initialLocation)
        
        // Set the mapview delegate
        mapView.delegate = self
        mapView.register(PinView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
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
    func centerOnMapLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, defaultZoomDistance, defaultZoomDistance)
            mapView.setRegion(coordinateRegion, animated: true)
    }

    // Debugger Textfield display
    
    
    // MARK: - Actions
    
    @IBAction func finished(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func reload(_ sender: Any) {
        performUIUpdatesOnMain {
            self.loadingView.isHidden = false
            
            self.activityIndicator.startAnimating()
        }
        
        print("Getting student locations...")
        //        temporaryGetStudentLocations()
        mapClient.getAllValidStudentLocations() {
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
                    self.fadeOutLoadingView(self.loadingView)
                } else {
                    self.displayTextOnUI(errorString!)
                    self.activityIndicator.stopAnimating()
                    self.fadeOutLoadingView(self.loadingView)
                    print(errorString!)
                }
            }
        }
    
    }
    
    func displayTextOnUI(_ displayString: String) {
        loadingTextField.text = displayString
        loadingTextField.alpha = 1.0
    }
    
    @IBAction func addPin(_ sender: Any) {
    }
    
    @IBAction func logOut(_ sender: Any) {
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
        guard  let annotation = annotation as? VerifiedStudent else {
            return nil
        }
        
        let identifier = "student"
        var view: MKMarkerAnnotationView
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequedView.annotation = annotation
            view = dequedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
