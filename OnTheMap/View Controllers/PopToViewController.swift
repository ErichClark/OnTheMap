//
//  popToViewController.swift
//  OnTheMap
//
//  Created by Erich Clark on 10/1/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//
// Big thanks to Budidino! https://stackoverflow.com/users/611879/budidino

import UIKit

extension UINavigationController {

    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }

}
