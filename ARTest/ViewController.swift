//
//  ViewController.swift
//  ARTest
//
//  Created by Al Wold on 9/3/17.
//  Copyright © 2017 Al Wold. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import os.log

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var scene: SCNScene!
    var spotlight: SCNLight!
    var planesByAnchorIdentifier = [UUID: SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!

        scene = SCNScene()
        sceneView.autoenablesDefaultLighting = false
        sceneView.automaticallyUpdatesLighting = false
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
//        let scene = createSampleScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addSpotlight(node: scene.rootNode)
        
        printLightInfo(node: scene.rootNode)
    }
    
    func printLightInfo(node: SCNNode) {
        os_log("node: %@", node)
        if let light = node.light {
            os_log("found light: %@", light)
        }
        for childNode in node.childNodes {
            printLightInfo(node: childNode)
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        addBall()
    }
    
    func addSpotlight(node: SCNNode) {
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .spot
        light.spotInnerAngle = 45
        light.spotOuterAngle = 45
        spotlight = light
        lightNode.light = light
        lightNode.position = SCNVector3(0, 0.5, -0.5)
        // point down
        lightNode.eulerAngles = SCNVector3(-Double.pi / 2, 0, 0);
        node.addChildNode(lightNode)
    }
    
    func addBall() {
        let ballGeometry = SCNSphere(radius: 0.1)
        ballGeometry.firstMaterial!.diffuse.contents = UIColor.red
        let ballNode = SCNNode(geometry: ballGeometry)
        ballNode.position = SCNVector3(0, 0, -0.5)
        ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//        os_log("number of materials: %d", ballNode.geometry!.materials.count)
//        if let material = ballNode.geometry?.firstMaterial {
//            os_log("material: %@", material)
//            material.metalness.contents = UIColor(white: 0.75, alpha: 1.0)
//        } else {
//            os_log("no material")
//        }
        scene.rootNode.addChildNode(ballNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let lightEstimate = frame.lightEstimate {
//            os_log("got light estimate: %@", lightEstimate)
            spotlight.intensity = lightEstimate.ambientIntensity
//            os_log("set intensity to %f", spotlight.intensity)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            os_log("got plane")
            let plane = createPlane(anchor: anchor)
            sceneView.scene.rootNode.addChildNode(plane)
            planesByAnchorIdentifier[anchor.identifier] = plane
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor, let plane = planesByAnchorIdentifier[anchor.identifier], let geometry = plane.geometry as? SCNPlane {
            os_log("updating plane")
            geometry.width = CGFloat(anchor.extent.x)
            geometry.height = CGFloat(anchor.extent.y)
            plane.position = SCNVector3(anchor.center.x, 0, anchor.center.y)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor, let plane = planesByAnchorIdentifier[anchor.identifier] {
            os_log("removing plane")
            plane.removeFromParentNode()
        }
    }
    
    func createPlane(anchor: ARPlaneAnchor) -> SCNNode {
        let planeNode = SCNNode()
        let geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        planeNode.geometry = geometry
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.y)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2.0, 1.0, 0.0, 0.0)
        planeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        return planeNode
    }
}
