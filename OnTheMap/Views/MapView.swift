//
//  MapView.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/4/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import MapKit

class PinView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let student = newValue as? StudentLocation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            
            // MARK: - Safari button
            let safariButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            safariButton.setBackgroundImage(UIImage(named: "safari_icon"), for: UIControlState())
            rightCalloutAccessoryView = safariButton
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = student.mediaURL
            detailCalloutAccessoryView = detailLabel
        }
    }
}
