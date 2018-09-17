//
//  FadeOut.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/13/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func fadeOutLoadingView(_ sender: UIView) {
        UIView.animate(withDuration: 1.5, delay: 0.1, options: .curveEaseOut, animations: {
            sender.alpha = 0.0
        })
    }
    func fadeInLoadingView(_ sender: UIView) {
        UIView.animate(withDuration: 1.5, delay: 0.1, options: .curveEaseIn, animations: {
            sender.alpha = 1.0
        })
    }
}
