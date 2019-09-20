//
//  Objects.swift
//  ARKitDemoGit
//
//  Created by Mac-06 on 14/09/19.
//  Copyright © 2019 Mac-06. All rights reserved.
//

import UIKit
import ARKit
import SceneKit.ModelIO

let kStartingPosition = SCNVector3(0, 0, -0.6)
let kAnimationDurationMoving: TimeInterval = 0.2
let kMovingLengthPerLoop: CGFloat = 0.08

//for swipe
//let kRotationRadianPerLoop: CGFloat = 2

//for pan
let kRotationRadianPerLoop: CGFloat = 0.05

class Drone : SCNNode{
    func loadModel()  {
        guard let virtualObjectScene = SCNScene(named: "Drone_obj.obj") else {
            return
        }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes{
            print(child.name ?? "No name")
            child.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Ground_Col")
            child.scale = SCNVector3(0.4, 0.4 , 0.4)
            wrapperNode.addChildNode(child)
        }
        addChildNode(wrapperNode)
    }
    
    
}

class Objects: NSObject {
    
}


extension float4x4{
    var translation : float3{
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
