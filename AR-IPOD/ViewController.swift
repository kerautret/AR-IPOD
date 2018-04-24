//
//  ViewController.swift
//  AR-IPOD
//
//  Created by Remi Decelle on 19/04/2018.
//  Copyright © 2018 Remi Decelle. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var myVolume: Volume = Volume.sharedInstance
    var depthImage: DepthImage = DepthImage(_width: 360, _heigth: 480)
    var myCamera: Camera = Camera()
    
    @IBOutlet weak var depthView: UIImageView!
    var myDepthStrings = [String]()
    var myDepthImage: UIImage?
    var myFocus: CGFloat = 0.5
    var mySlope: CGFloat = 4.0
    var myDepthData: AVDepthData?
    var myDepthDataRaw: AVDepthData?
    var myCIImage: CIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        //let configuration = ARWorldTrackingConfiguration()
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        // Initialize Volume
        /*
        var z: UInt16   = 3
        let m: Float    = 43.0
        let n: UInt16   = 43
        let start   = CFAbsoluteTimeGetCurrent()
        for _ in 0..<1_000_000 {
            z = n
        }
        let end    = CFAbsoluteTimeGetCurrent()
        let elapsedTime = Double(end) - Double(start)
        print("Time : \(elapsedTime)")
         */
        let mem = MemoryLayout<Voxel>.size
        let ali = MemoryLayout<Voxel>.alignment
        let str = MemoryLayout<Voxel>.stride
        print("Size: \(mem) \n Alignement: \(ali) \n Stride: \(str)")
 
        if let frame = sceneView.session.currentFrame {
            myCamera = Camera(_intrinsics: frame.camera.intrinsics, dim: frame.camera.imageResolution)
            myCamera.update(position: frame.camera.transform)
            myVolume.initialize()
        }
        else {
            assertionFailure("Camera has not been initialized ! ")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
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
        // Capture DepthMap
        if frame.capturedDepthData != nil {
            myDepthData = frame.capturedDepthData?.converting(toDepthDataType: kCVPixelFormatType_DepthFloat32)
            myDepthDataRaw =  frame.capturedDepthData
            let depthDataMap = myDepthData?.depthDataMap
            CVPixelBufferLockBaseAddress(depthDataMap!, CVPixelBufferLockFlags(rawValue: 0))
            let depthPointer = unsafeBitCast(CVPixelBufferGetBaseAddress(depthDataMap!), to: UnsafeMutablePointer<Float>.self)
            /*
             * Potential Pre-processing : Median Filter.
             * We have to convert depthDataMap into an UIImage to do this.
            compCIImage(depthDataMap: depthDataMap!)
            myDepthImage = UIImage(ciImage: myCIImage!)
            depthView.image = myDepthImage
            */
            depthImage.update(_data: depthPointer)
        }
        myCamera.update(position: frame.camera.transform)
        myVolume.integrateDepthMap(image: depthImage, camera: myCamera)
    }
}
