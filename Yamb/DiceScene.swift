//
//  DiceScene.swift
//  Yamb
//
//  Created by prcela on 16/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import SceneKit

class DiceScene: SCNScene
{
    static let shared = DiceScene()
    
    override init() {
        super.init()
        
        let side: CGFloat = 1
        let deltaX: Float = 0.5
        
        for dieIdx in 0...4
        {
            let die = SCNBox(width: side, height: side, length: side, chamferRadius: 0.1)
            
            let dieNode = SCNNode(geometry: die)
            dieNode.position = SCNVector3Make(Float(dieIdx)*(Float(side)+deltaX)+0.5*Float(side), 0, 0)
            rootNode.addChildNode(dieNode)
            
            var materials = [SCNMaterial]()
            for sideIdx in 1...6
            {
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(named: String(sideIdx))
                material.locksAmbientWithDiffuse = false
                materials.append(material)
            }
            
            
            die.materials = materials
        }
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 1.2
        cameraNode.position = SCNVector3Make(3.5, 0, 30)
        
        
        
//                cameraNode.rotation = SCNVector4Make(1, 0, 0, -atan2(10, 20))
        
        rootNode.addChildNode(cameraNode)
        
        let light = SCNLight()
        light.type = SCNLightTypeDirectional
        light.color = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        let lightNode = SCNNode()
        lightNode.light = light
        cameraNode.addChildNode(lightNode)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
