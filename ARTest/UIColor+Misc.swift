//
//  UIColor+Misc.swift
//  FirstTryARKit
//
//  Created by Xidong Wang on 9/13/17.
//  Copyright © 2017 Xidong Wang. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var random: UIColor {
        get {
            return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
        }
    }
    
    static var transparentWhite: UIColor {
        get {
            return UIColor(white: 1.0, alpha: 0.3)
        }
    }
}
