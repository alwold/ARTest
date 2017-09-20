//
//  Plane.swift
//  ARTest
//
//  Created by Al Wold on 9/20/17.
//  Copyright © 2017 Al Wold. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import os.log

class Plane: SCNNode {
    var actualWidth: CGFloat
    var actualHeight: CGFloat
    let plane: SCNBox
    var visible = false {
        didSet {
            updateColor()
        }
    }

    init(anchor: ARPlaneAnchor) {
        actualWidth = CGFloat(anchor.extent.x)
        actualHeight = CGFloat(anchor.extent.z)
        plane = SCNBox(width: actualWidth, height: 0.01, length: actualHeight, chamferRadius: 0.0)
        os_log("plane size: %f x %f", plane.width, plane.length)

        super.init()

        updateColor()
        self.geometry = plane
        self.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        os_log("position: %@", anchor.center.debugDescription)
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use this initializer")
    }
    
    func update(anchor: ARPlaneAnchor) {
        os_log("updating plane")
        actualWidth = CGFloat(anchor.extent.x)
        actualHeight = CGFloat(anchor.extent.z)
        if !isGiant {
            plane.width = actualWidth
            plane.length = actualHeight
        }
        self.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
    }
    
    var isGiant: Bool = false {
        didSet {
            if isGiant {
                // set plane to big size, so it covers the whole floor
                plane.width = 100
                plane.length = 100
                updateColor()
                physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: plane))
                os_log("physics body now: %@", physicsBody!)
            } else {
                // set plane to its normal size
                plane.width = actualWidth
                plane.length = actualHeight
                updateColor()
                physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: plane))
            }
        }
    }
    
    func updateColor() {
        if visible {
            if isGiant {
                plane.firstMaterial!.diffuse.contents = UIColor(red: 1, green: 0, blue: 0, alpha: 0.6)
            } else {
                plane.firstMaterial!.diffuse.contents = UIColor(red: 1, green: 0, blue: 0, alpha: 0.6)
            }
        } else {
            plane.firstMaterial!.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)
        }
    }
}
