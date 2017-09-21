//
//  Ball.swift
//  ARTest
//
//  Created by Al Wold on 9/21/17.
//  Copyright © 2017 Al Wold. All rights reserved.
//

import SceneKit
import ARKit

class Ball: SCNNode {
    static let ballDropHeight: Float = 2.0

    init(position: SCNVector3, color: UIColor = .random()) {
        super.init()
        geometry = SCNSphere(radius: 0.1)
        geometry!.firstMaterial!.diffuse.contents = color
        self.position = position
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    }
    
    convenience init(hitResult: ARHitTestResult) {
        // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane using the physics engine
        let hitPosition = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        self.init(hitPosition: hitPosition)
    }
    
    convenience init(hitPosition: SCNVector3) {
        var ballPosition = hitPosition
        ballPosition.y += Ball.ballDropHeight
        self.init(position: ballPosition)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Unarchiving not supported")
    }
}
