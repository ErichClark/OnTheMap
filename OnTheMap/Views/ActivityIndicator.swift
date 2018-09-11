//
//  ActivityIndicator.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/10/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class func showSpinner(onView: UIView) -> UIView {
        let spinnerView = UIView.init()
        spinnerView.backgroundColor = .gray
        let activityIndicator = UIActivityIndicatorView.init()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        
        performUIUpdatesOnMain {
            spinnerView.addSubview(spinnerView)
            onView.addSubview(spinnerView)
        }
         return spinnerView
    }
    
    class func hideSpinner(spinner: UIView) {
        performUIUpdatesOnMain {
            spinner.removeFromSuperview()
        }
    }
}
