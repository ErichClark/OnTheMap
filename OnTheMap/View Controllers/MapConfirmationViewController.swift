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

    
    // MARK: - Actions
    @IBAction func confirmMapLocation(_ sender: Any) {
    
    
    }
    
    @IBAction func backToTextSearch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapConfirmationViewController: MKMapViewDelegate {
    
}
