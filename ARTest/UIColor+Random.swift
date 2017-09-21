//
//  UIColor+Random.swift
//  ARTest
//
//  Created by Al Wold on 9/21/17.
//  Copyright © 2017 Al Wold. All rights reserved.
//

import UIKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
}
