//
//  Plane.swift
//  FirstTryARKit
//
//  Created by Xidong Wang on 9/10/17.
//  Copyright © 2017 Xidong Wang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNBox!
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor
        let width: CGFloat = CGFloat(anchor.extent.x)
        let length: CGFloat = CGFloat(anchor.extent.z)
        
        let planeHeight: CGFloat = 0.01
        self.planeGeometry = SCNBox(width: width, height: planeHeight, length: length, chamferRadius: 0.0)
        self.planeGeometry.firstMaterial!.diffuse.contents = UIColor.transparentWhite
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3Make(0, Float(CGFloat(-planeHeight / 2)), 0)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        
        setTextureScale()
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setTextureScale() {
        let width: Float = Float(self.planeGeometry.width)
        let height: Float = Float(self.planeGeometry.length)
        
        let material = self.planeGeometry.firstMaterial
        
        let scaleFactor: Float = 1
        let m: SCNMatrix4 = SCNMatrix4MakeScale(width * scaleFactor, height * scaleFactor, 1)
        material?.diffuse.contentsTransform = m
        material?.roughness.contentsTransform = m
        material?.metalness.contentsTransform = m
        material?.normal.contentsTransform = m
    }
    
    func update(anchor: ARPlaneAnchor) {
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.length = CGFloat(anchor.extent.z)
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        
        if let node = self.childNodes.first {
            let shape = SCNPhysicsShape(geometry: self.planeGeometry, options: nil)
            node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
            setTextureScale()
        }
    }
}
