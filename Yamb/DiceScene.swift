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
    
    var playSoundAction: SCNAction?
    
    override init() {
        super.init()
        
        let side: CGFloat = 1
        let delta: Float = 0.25
        
        for dieIdx in 0..<Game.shared.diceNum.rawValue
        {
            let die = SCNBox(width: side, height: side, length: side, chamferRadius: 0.1)
            
            let row = dieIdx / 3
            let col = dieIdx % 3
            
            let dieNode = SCNNode(geometry: die)
            dieNode.name = String(dieIdx)
            dieNode.position = SCNVector3Make(Float(col)*(Float(side)+delta)+0.5*Float(side), Float(row)*(Float(side)+delta), 0)
            rootNode.addChildNode(dieNode)
            
            var materials = [SCNMaterial]()
            for sideIdx in 1...6
            {
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(named: String(sideIdx))
                material.locksAmbientWithDiffuse = true
                materials.append(material)
            }
            
            
            die.materials = materials
        }
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 1.5
        cameraNode.position = SCNVector3Make(2, 0.5*Float(side) + 0.5*delta, 30)
        
        rootNode.addChildNode(cameraNode)
        
        let light = SCNLight()
        light.type = SCNLightTypeDirectional
        light.color = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        let lightNode = SCNNode()
        lightNode.light = light
        cameraNode.addChildNode(lightNode)
        
        
        if #available(iOS 9.0, *) {
            
            let dieNode = rootNode.childNodeWithName("0", recursively: false)!
            let audioSource = SCNAudioSource(fileNamed: "6.m4a")!
            let audioPlayer = SCNAudioPlayer(source: audioSource)
            
            dispatch_async(dispatch_get_main_queue(), { 
                dieNode.addAudioPlayer(audioPlayer)
            })
            
            
            playSoundAction = SCNAction.playAudioSource(audioSource, waitForCompletion: false)
        }

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start()
    {
        let game = Game.shared
        if let node = rootNode.childNodeWithName("5", recursively: false)
        {
            node.hidden = game.diceNum == .Five
        }
    }

    func roll(completion: (result: [UInt]) -> Void)
    {
        let ctMaxRounds: UInt32 = 5
        var values = [UInt]()
        
        func randomRotateAngleToDst(dst:CGFloat) -> CGFloat
        {
            return dst + CGFloat(1+arc4random_uniform(ctMaxRounds))*2*CGFloat(M_PI)
        }
        
        for dieIdx in 0..<Game.shared.diceNum.rawValue
        {
            let num = UInt(1+arc4random_uniform(6))
            values.append(num)
            
            var rndX = randomRotateAngleToDst(0)
            var rndY = randomRotateAngleToDst(0)
            let rndZ = randomRotateAngleToDst(0)
            
            if num == 1
            {
                // ok
            }
            else if num == 2
            {
                rndY = randomRotateAngleToDst(-CGFloat(M_PI_2))
            }
            else if num == 3
            {
                rndY = randomRotateAngleToDst(CGFloat(M_PI))
            }
            else if num == 4
            {
                rndY = randomRotateAngleToDst(CGFloat(M_PI_2))
            }
            else if num == 5
            {
                rndX = randomRotateAngleToDst(CGFloat(M_PI_2))
            }
            else
            {
                rndX = randomRotateAngleToDst(-CGFloat(M_PI_2))
            }
            
            let action = SCNAction.rotateToX(rndX, y: rndY, z: rndZ, duration: 1)
            let node = rootNode.childNodeWithName(String(dieIdx), recursively: false)!
            node.runAction(action)
        }
        
        if playSoundAction != nil
        {
            let dieNode = rootNode.childNodeWithName("0", recursively: false)
            dieNode?.runAction(playSoundAction!)
        }
        
        dispatchToMainQueue(delay: 1.1) { 
            completion(result: values)
        }
    }

}


