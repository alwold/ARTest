//
//  SceneKitViewController.swift
//  ARTest
//
//  Created by Al Wold on 9/7/17.
//  Copyright © 2017 Al Wold. All rights reserved.
//

import UIKit
import SceneKit
import os.log

class SceneKitViewController: UIViewController {
    
    @IBOutlet var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = createBallsScene()
    }
    
    func createBallsScene() -> SCNScene {
        let scene = SCNScene()
        let ballNode = SCNNode(geometry: SCNSphere(radius: 10))
        
        os_log("number of materials: %d", ballNode.geometry!.materials.count)
        if let material = ballNode.geometry?.firstMaterial {
            os_log("material: %@", material)
        } else {
            os_log("no material")
        }
        scene.rootNode.addChildNode(ballNode)
        return scene
    }
}
