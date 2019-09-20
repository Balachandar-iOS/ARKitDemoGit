//
//  ViewController.swift
//  ARKitDemoGit
//
//  Created by Mac-06 on 14/09/19.
//  Copyright © 2019 Mac-06. All rights reserved.
//

import UIKit
import ARKit
import SceneKit.ModelIO

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var panSegmentControl: UISegmentedControl!
    var drone = Drone()
    
    var currentAngleY: Float = 0.0
    
    var isRotating = false
    
    var previousPoint = CGPoint(x: 0, y: 0)
    var currentTouchPoint = CGPoint(x: 0, y: 0)
    
    
    var lastPanPosition: SCNVector3?
    var panStartPosition: CGFloat?
    var draggingNode: SCNNode?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPinchGesture()
        //addSwipeGesture()
        addPanGesturetoDrone()
        addTapGesture()
        setupScene()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        sceneView.showsStatistics = true
      
        addDrone()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    // MARK: - Setup
    func setupScene() {
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        //        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
    
    func addDrone(x: Float = 0, y: Float = 0, z: Float = -0.6){
        
        drone.loadModel()
        drone.position = SCNVector3(x,y,z)
        drone.rotation = SCNVector4Zero
        
        sceneView.scene.rootNode.addChildNode(drone)
    }
    
    
    
    
    
    //MARK: - Pan Gesture
    // Rotate using pan gesture
    
    
    func addPanGesturetoDrone()  {
        //        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode(_:)))
        //        sceneView.addGestureRecognizer(rotateGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(moveNode(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc func moveNode(_ gesture: UIPanGestureRecognizer) {
        
        
        if panSegmentControl.selectedSegmentIndex == 0{
            
        // Roatet
            if !isRotating{
                
                currentTouchPoint = gesture.location(in: self.sceneView)
                
                if(previousPoint.x == currentTouchPoint.x)
                {
                    return
                }
                if(previousPoint.x > currentTouchPoint.x){
                    rotateRightLongPressed(gesture)
                }
                else{
                    
                    rotateLeftLongPressed(gesture)
                }
                print(currentTouchPoint)
                previousPoint = currentTouchPoint
                
            }
        }
        else{
            // Move
            //        guard let view = self.view as? SCNView else { return }
            let location = gesture.location(in: self.sceneView)
            switch gesture.state {
            case .began:
                guard let hitNodeResult = sceneView.hitTest(location, options: nil).first else { return }
                panStartPosition = CGFloat(sceneView.projectPoint(hitNodeResult.node.worldPosition).z)
                draggingNode = hitNodeResult.node
            case .changed:
                guard panStartPosition != nil, draggingNode != nil else { return }
                let worldTouchPosition = sceneView.unprojectPoint(SCNVector3(location.x, location.y, panStartPosition!))
                
                drone.position = worldTouchPosition
            case .ended:
                (panStartPosition, draggingNode) = (nil, nil)
            default:
                break
            }
        }
    }
    
    
    // MARK: - Pinch Gesture
    // Zooming
    
    func addPinchGesture(){
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleObject(gesture:)))
        sceneView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func scaleObject(gesture : UIPinchGestureRecognizer){
        
        if gesture.state == .changed {
            let location = gesture.location(in: sceneView)
            
            let hitResults = sceneView.hitTest(location, options : nil)
            
            if let hitPoints = hitResults.first{
                let eachNode = hitPoints.node
                
                let newScaleX = Float(gesture.scale) * eachNode.scale.x
                let newScaleY = Float(gesture.scale) * eachNode.scale.y
                let newScaleZ = Float(gesture.scale) * eachNode.scale.z
                
                eachNode.scale = SCNVector3(x: newScaleX, y: newScaleY, z: newScaleZ)
                
                gesture.scale = 1
            }
        }
        
    }
    
    
    // MARK: - Tap Gesture
    // Removing and adding an object
    
    func addTapGesture(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.disTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func disTap(withGestureRecognizer recognizer: UIGestureRecognizer)  {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        
        print(hitTestResults.first?.node as Any)
        guard let node = hitTestResults.first?.node
            else {
                let hitResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
                if let hitResultsWithFeaturePoints = hitResultsWithFeaturePoints.first{
                    let translation = hitResultsWithFeaturePoints.worldTransform.translation
                    addDrone(x: translation.x, y: translation.y, z: translation.z)
                }
                return
                
        }
        node.removeFromParentNode()
    }
    
    // MARK: - Rotate
    
    @IBAction func rotateLeftLongPressed(_ sender: UIPanGestureRecognizer) {
        rotateDrone(yRadian: kRotationRadianPerLoop, sender: sender)
    }
    
    private func rotateDrone(yRadian: CGFloat, sender: UIPanGestureRecognizer) {
        let action = SCNAction.rotateBy(x: 0, y: yRadian, z: 0, duration: kAnimationDurationMoving)
        drone.runAction(action)
    }
    
    @IBAction func rotateRightLongPressed(_ sender: UIPanGestureRecognizer) {
        rotateDrone(yRadian: -kRotationRadianPerLoop, sender: sender)
    }
    
    
    @IBAction func segmentControlValuechanges(_ sender: Any) {
        
    }
    
    /*
     // MARK: - Swipe Gesture
     
     // Swipe to rotate
     func addSwipeGesture(){
     
     
     let directions: [UISwipeGestureRecognizerDirection] = [.up, .down, .right, .left]
     for direction in directions {
     let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeNode(_:)))
     gesture.direction = direction
     sceneView.addGestureRecognizer(gesture)
     }
     
     
     }
     
     
     @objc  func swipeNode(_ gesture: UISwipeGestureRecognizer) {
     currentTouchPoint = gesture.location(in: self.sceneView)
     
     //        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
     //        switch swipeGesture.direction {
     //        case UISwipeGestureRecognizerDirection.right:
     //            rotateLeftLongPressed(gesture)
     //        case UISwipeGestureRecognizerDirection.left:
     //          rotateRightLongPressed(gesture)
     //        default:
     //            return
     //        }
     //        }
     //
     }
     
     private func execute(action: SCNAction, sender: UIPanGestureRecognizer) {
     //        let loopAction = SCNAction.repeatForever(action)
     //        if sender.state == .began {
     //            if(currentTouchPoint.x == previousPoint.x){
     //                drone.removeAllActions()
     //            }
     //            drone.runAction(loopAction)
     //        drone.runAction(loopAction){
     //            self.drone.removeAllActions()
     //        }
     
     
     //        } else if sender.state == .ended {
     //             drone.removeAllActions()
     //        }
     }
     */
    
}

