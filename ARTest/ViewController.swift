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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, SettingsDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    var scene: SCNScene!
    var spotlight: SCNLight!
    var planesByAnchorIdentifier = [UUID: Plane]()
    var showPlanes = false {
        didSet {
            for plane in planesByAnchorIdentifier.values {
                plane.visible = showPlanes
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!

        scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
//        sceneView.automaticallyUpdatesLighting = false
        sceneView.debugOptions = [/*ARSCNDebugOptions.showWorldOrigin,*/ ARSCNDebugOptions.showFeaturePoints]
//        let scene = createSampleScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
//        addSpotlight(node: scene.rootNode)
        
        printLightInfo(node: scene.rootNode)
        
        setupFocusSquare()
//        addFakeFloorPlane()
        
        statusLabel.isHidden = true
        statusLabel.backgroundColor = .white
        statusLabel.layer.borderColor = UIColor.black.cgColor
        statusLabel.layer.borderWidth = 2
        statusLabel.layer.cornerRadius = 3
        updateStats()
        setupRecognizers()
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
    
    func addFakeFloorPlane() {
        let plane = SCNBox(width: 10, height: 0.01, length: 10, chamferRadius: 0.0)
        plane.firstMaterial!.diffuse.contents = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(0, -2, 0)
//        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2.0, 1.0, 0.0, 0.0)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        sceneView.scene.rootNode.addChildNode(planeNode)
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
    
    func addBall(position: SCNVector3 = SCNVector3(0, 0, -0.5), color: UIColor = UIColor.red) {
        let ballGeometry = SCNSphere(radius: 0.1)
        ballGeometry.firstMaterial!.diffuse.contents = color
        let ballNode = SCNNode(geometry: ballGeometry)
        ballNode.position = position
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateFocusSquare()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let lightEstimate = frame.lightEstimate {
//            os_log("got light estimate: %@", lightEstimate)
//            spotlight.intensity = lightEstimate.ambientIntensity
//            os_log("set intensity to %f", spotlight.intensity)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            os_log("got plane")
            let plane = Plane(anchor: anchor)
            node.addChildNode(plane)
            planesByAnchorIdentifier[anchor.identifier] = plane
            showStatusText(text: "Added plane")
            updateStats()
            extendLowestPlane()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor, let plane = planesByAnchorIdentifier[anchor.identifier] {
            plane.update(anchor: anchor)
            extendLowestPlane()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor, let plane = planesByAnchorIdentifier[anchor.identifier] {
            os_log("removing plane")
            plane.removeFromParentNode()
            planesByAnchorIdentifier.removeValue(forKey: anchor.identifier)
            updateStats()
        }
    }
    
    func showStatusText(text: String) {
        DispatchQueue.main.async {
            self.statusLabel.isHidden = false
            self.statusLabel.text = text
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                self.statusLabel.isHidden = true
            }
        }
    }
    
    func updateStats() {
        DispatchQueue.main.async {
            self.statsLabel.text = "\(self.planesByAnchorIdentifier.count) planes"
        }
    }
    
    func extendLowestPlane() {
        var lowestY = Float.infinity
        var lowestPlane: Plane?
        for plane in planesByAnchorIdentifier.values {
            let parentY = plane.parent!.position.y // get the Y position of the plane anchor node added by ARKit
            let translateY = plane.position.y
            let actualY = parentY + translateY
            if actualY < lowestY {
                lowestPlane = plane
                lowestY = actualY
            }
        }
        if let lowestPlane = lowestPlane {
            os_log("setting plane to giant: %@", lowestPlane)
            lowestPlane.isGiant = true
        }
        for plane in planesByAnchorIdentifier.values {
            if plane !== lowestPlane {
//                os_log("setting plane to not giant: %@", plane)
                plane.isGiant = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsViewController = segue.destination as? SettingsViewController {
            settingsViewController.delegate = self
            settingsViewController.showPlanes = showPlanes
        }
    }
    
    // MARK: - Tap to drop ball
    func setupRecognizers() {
        // Single tap will insert a new piece of geometry into the scene
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(sender:)))
        tap.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tap)
    }

    @objc func viewTapped(sender: UITapGestureRecognizer) {
        os_log("Tap!")
        // Take the screen space tap coordinates and pass them to the hitTest method on the ARSCNView instance
        let tapPoint = sender.location(in: sceneView)
        
        if let hitResult = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent).first {
            os_log("got arkit hit")
            addBall(hitResult: hitResult)
        } else {
            let hitResult = sceneView.hitTest(tapPoint, options: nil)
            if !hitResult.isEmpty {
                os_log("got scenekit hits")
                var position = hitResult.first!.worldCoordinates
                position.y += 0.5
                addBall(hitPosition: position)
            } else {
                os_log("no hits")
            }
        }
    }
    
    func addBall(hitResult: ARHitTestResult) {
        // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane using the physics engine
        let insertionYOffset: Float = 0.5
        let position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            Float(hitResult.worldTransform.columns.3.y + insertionYOffset),
            Float(hitResult.worldTransform.columns.3.z)
        )
        addBall(hitPosition: position)
    }
    
    func addBall(hitPosition: SCNVector3) {
        // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane using the physics engine
        let randomColor = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)

        addBall(position: hitPosition, color: randomColor)
    }

    // MARK: Focus indicator
    var screenCenter: CGPoint?
    var focusSquare: FocusSquare?
    
    func setupFocusSquare() {
        DispatchQueue.main.async {
            self.screenCenter = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        }
        
        DispatchQueue.main.async {
            self.focusSquare?.isHidden = true
            self.focusSquare?.removeFromParentNode()
            self.focusSquare = FocusSquare()
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare!)
        }
    }
    
    func updateFocusSquare() {
        guard let screenCenter = screenCenter else { return }
        
        DispatchQueue.main.async {
            self.focusSquare?.unhide()
            
            let (worldPos, planeAnchor, _) = self.worldPositionFromScreenPosition(screenCenter, in: self.sceneView, objectPos: self.focusSquare?.simdPosition)
            
            if let worldPos = worldPos {
                self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.sceneView.session.currentFrame?.camera)
            }
        }
    }
    
    func worldPositionFromScreenPosition(_ position: CGPoint, in sceneView: ARSCNView, objectPos: float3?, infinitePlane: Bool = false) -> (position: float3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = result.worldTransform.translation
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
    
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: float3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if (infinitePlane) || !highQualityFeatureHitTestResult {
            
            if let pointOnPlane = objectPos {
                let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
                if pointOnInfinitePlane != nil {
                    return (pointOnInfinitePlane, nil, true)
                }
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        return (nil, nil, false)
    }
}

extension ARSCNView {
    
    // MARK: - Types
    
    struct HitTestRay {
        let origin: float3
        let direction: float3
    }
    
    struct FeatureHitTestResult {
        let position: float3
        let distanceToRayOrigin: Float
        let featureHit: float3
        let featureDistanceToHitResult: Float
    }
    
    func unprojectPoint(_ point: float3) -> float3 {
        return float3(self.unprojectPoint(SCNVector3(point)))
    }
    
    // MARK: - Hit Tests
    
    func hitTestRayFromScreenPos(_ point: CGPoint) -> HitTestRay? {
        
        guard let frame = self.session.currentFrame else {
            return nil
        }
        
        let cameraPos = frame.camera.transform.translation
        
        // Note: z: 1.0 will unproject() the screen position to the far clipping plane.
        let positionVec = float3(x: Float(point.x), y: Float(point.y), z: 1.0)
        let screenPosOnFarClippingPlane = self.unprojectPoint(positionVec)
        
        let rayDirection = simd_normalize(screenPosOnFarClippingPlane - cameraPos)
        return HitTestRay(origin: cameraPos, direction: rayDirection)
    }
    
    func hitTestWithInfiniteHorizontalPlane(_ point: CGPoint, _ pointOnPlane: float3) -> float3? {
        
        guard let ray = hitTestRayFromScreenPos(point) else {
            return nil
        }
        
        // Do not intersect with planes above the camera or if the ray is almost parallel to the plane.
        if ray.direction.y > -0.03 {
            return nil
        }
        
        // Return the intersection of a ray from the camera through the screen position with a horizontal plane
        // at height (Y axis).
        return rayIntersectionWithHorizontalPlane(rayOrigin: ray.origin, direction: ray.direction, planeY: pointOnPlane.y)
    }
    
    func hitTestWithFeatures(_ point: CGPoint, coneOpeningAngleInDegrees: Float,
                             minDistance: Float = 0,
                             maxDistance: Float = Float.greatestFiniteMagnitude,
                             maxResults: Int = 1) -> [FeatureHitTestResult] {
        
        var results = [FeatureHitTestResult]()
        
        guard let features = self.session.currentFrame?.rawFeaturePoints else {
            return results
        }
        
        guard let ray = hitTestRayFromScreenPos(point) else {
            return results
        }
        
        let maxAngleInDeg = min(coneOpeningAngleInDegrees, 360) / 2
        let maxAngle = (maxAngleInDeg / 180) * .pi
        
        let points = features.__points
        
        for i in 0...features.__count {
            
            let feature = points.advanced(by: Int(i))
            let featurePos = feature.pointee
            
            let originToFeature = featurePos - ray.origin
            
            let crossProduct = simd_cross(originToFeature, ray.direction)
            let featureDistanceFromResult = simd_length(crossProduct)
            
            let hitTestResult = ray.origin + (ray.direction * simd_dot(ray.direction, originToFeature))
            let hitTestResultDistance = simd_length(hitTestResult - ray.origin)
            
            if hitTestResultDistance < minDistance || hitTestResultDistance > maxDistance {
                // Skip this feature - it is too close or too far away.
                continue
            }
            
            let originToFeatureNormalized = simd_normalize(originToFeature)
            let angleBetweenRayAndFeature = acos(simd_dot(ray.direction, originToFeatureNormalized))
            
            if angleBetweenRayAndFeature > maxAngle {
                // Skip this feature - is is outside of the hit test cone.
                continue
            }
            
            // All tests passed: Add the hit against this feature to the results.
            results.append(FeatureHitTestResult(position: hitTestResult,
                                                distanceToRayOrigin: hitTestResultDistance,
                                                featureHit: featurePos,
                                                featureDistanceToHitResult: featureDistanceFromResult))
        }
        
        // Sort the results by feature distance to the ray.
        results = results.sorted(by: { (first, second) -> Bool in
            return first.distanceToRayOrigin < second.distanceToRayOrigin
        })
        
        // Cap the list to maxResults.
        var cappedResults = [FeatureHitTestResult]()
        var i = 0
        while i < maxResults && i < results.count {
            cappedResults.append(results[i])
            i += 1
        }
        
        return cappedResults
    }
    
    func hitTestWithFeatures(_ point: CGPoint) -> [FeatureHitTestResult] {
        
        var results = [FeatureHitTestResult]()
        
        guard let ray = hitTestRayFromScreenPos(point) else {
            return results
        }
        
        if let result = self.hitTestFromOrigin(origin: ray.origin, direction: ray.direction) {
            results.append(result)
        }
        
        return results
    }
    
    func hitTestFromOrigin(origin: float3, direction: float3) -> FeatureHitTestResult? {
        
        guard let features = self.session.currentFrame?.rawFeaturePoints else {
            return nil
        }
        
        let points = features.__points
        
        // Determine the point from the whole point cloud which is closest to the hit test ray.
        var closestFeaturePoint = origin
        var minDistance = Float.greatestFiniteMagnitude
        
        for i in 0...features.__count {
            let feature = points.advanced(by: Int(i))
            let featurePos = feature.pointee
            
            let originVector = origin - featurePos
            let crossProduct = simd_cross(originVector, direction)
            let featureDistanceFromResult = simd_length(crossProduct)
            
            if featureDistanceFromResult < minDistance {
                closestFeaturePoint = featurePos
                minDistance = featureDistanceFromResult
            }
        }
        
        // Compute the point along the ray that is closest to the selected feature.
        let originToFeature = closestFeaturePoint - origin
        let hitTestResult = origin + (direction * simd_dot(direction, originToFeature))
        let hitTestResultDistance = simd_length(hitTestResult - origin)
        
        return FeatureHitTestResult(position: hitTestResult,
                                    distanceToRayOrigin: hitTestResultDistance,
                                    featureHit: closestFeaturePoint,
                                    featureDistanceToHitResult: minDistance)
    }
    
}

func rayIntersectionWithHorizontalPlane(rayOrigin: float3, direction: float3, planeY: Float) -> float3? {
    
    let direction = simd_normalize(direction)
    
    // Special case handling: Check if the ray is horizontal as well.
    if direction.y == 0 {
        if rayOrigin.y == planeY {
            // The ray is horizontal and on the plane, thus all points on the ray intersect with the plane.
            // Therefore we simply return the ray origin.
            return rayOrigin
        } else {
            // The ray is parallel to the plane and never intersects.
            return nil
        }
    }
    
    // The distance from the ray's origin to the intersection point on the plane is:
    //   (pointOnPlane - rayOrigin) dot planeNormal
    //  --------------------------------------------
    //          direction dot planeNormal
    
    // Since we know that horizontal planes have normal (0, 1, 0), we can simplify this to:
    let dist = (planeY - rayOrigin.y) / direction.y
    
    // Do not return intersections behind the ray's origin.
    if dist < 0 {
        return nil
    }
    
    // Return the intersection point.
    return rayOrigin + (direction * dist)
}
