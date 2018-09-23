//
//  FadingTextHelper.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/13/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func fadeOutTextField(_ sender: UITextField) {
        sender.alpha = 1
        
        UIView.animate(withDuration: 50, delay: 10, options: .curveEaseOut, animations: {
            sender.alpha = 0.0
        })
        sender.text = "faded"
        sender.alpha = 1
    }
    func fadeInTextField(_ sender: UIView) {
        UIView.animate(withDuration: 1.5, delay: 0.1, options: .curveEaseIn, animations: {
            sender.alpha = 1.0
        })
    }
}
