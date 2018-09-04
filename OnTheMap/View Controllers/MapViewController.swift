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

    let centralStudentPin = StudentLocation()
    let defaultZoomDistance = CLLocationDistance(MapClient.Constants.DefaultMapZoom)
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lowerTabBar: UITabBarItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLocation = CLLocation(latitude: centralStudentPin.latitude!, longitude: centralStudentPin.longitude!)
        // Do any additional setup after loading the view.
        centerOnMapLocation(location: initialLocation)
    }

    func centerOnMapLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, defaultZoomDistance, defaultZoomDistance)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func finished(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func reload(_ sender: Any) {
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
