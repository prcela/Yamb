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
    
    var dieMaterialsDefault = [SCNMaterial]()
    var dieMaterialsSelected = [SCNMaterial]()
    
    var activeRotationRounds = Array<Array<UInt32>>(count: 6, repeatedValue: [0,0,0])
    
    override init() {
        super.init()
        
        let side: CGFloat = 1
        let delta: Float = 0.25
        
        for sideIdx in 1...6
        {
            let defaultMaterial = SCNMaterial()
            let name = String(sideIdx)
            defaultMaterial.diffuse.contents = UIImage(named: name)
            defaultMaterial.locksAmbientWithDiffuse = true
            dieMaterialsDefault.append(defaultMaterial)
            
            let selectedMaterial = SCNMaterial()
            let selName = "\(sideIdx)b"
            selectedMaterial.diffuse.contents = UIImage(named: selName)
            selectedMaterial.locksAmbientWithDiffuse = true
            dieMaterialsSelected.append(selectedMaterial)
        }
        
        for dieIdx in 0..<Game.shared.diceNum.rawValue
        {
            let die = SCNBox(width: side, height: side, length: side, chamferRadius: 0.1)
            
            let row = dieIdx / 3
            let col = dieIdx % 3
            
            let dieNode = SCNNode(geometry: die)
            dieNode.name = String(dieIdx)
            dieNode.position = SCNVector3Make(Float(col)*(Float(side)+delta)+0.5*Float(side), Float(row)*(Float(side)+delta), 0)
            rootNode.addChildNode(dieNode)
            
            die.materials = dieMaterialsDefault
        }
        
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 1.5
        cameraNode.position = SCNVector3Make(1.5*Float(side)+delta, 0.5*Float(side) + 0.5*delta, 30)
        
        rootNode.addChildNode(cameraNode)
        
        let light = SCNLight()
        light.type = SCNLightTypeDirectional
        light.color = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        let lightNode = SCNNode()
        lightNode.light = light
        cameraNode.addChildNode(lightNode)
        
        
        if #available(iOS 9.0, *) {
            
            let audioSource = SCNAudioSource(fileNamed: "6.m4a")!
            let audioPlayer = SCNAudioPlayer(source: audioSource)
            
            dispatch_async(dispatch_get_main_queue(), { 
                cameraNode.addAudioPlayer(audioPlayer)
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
        updateDiceSelection()
    }

    func roll(completion: (result: [UInt]) -> Void)
    {
        let ctMaxRounds: UInt32 = 5
        var oldValues = Game.shared.diceValues
        var values = [UInt]()
        
        func rotateAngleToDst(dst:CGFloat, rounds: UInt32) -> CGFloat
        {
            return dst + CGFloat(rounds)*2*CGFloat(M_PI)
        }
        
        for dieIdx in 0..<Game.shared.diceNum.rawValue
        {
            if Game.shared.diceHeld.contains(UInt(dieIdx))
            {
                // skip it by adding same value
                values.append(oldValues?[dieIdx] ?? 1)
                continue
            }
            
            let num = UInt(1+arc4random_uniform(6))
            values.append(num)
            
            var newRounds = [1+arc4random_uniform(ctMaxRounds),
                             1+arc4random_uniform(ctMaxRounds),
                             1+arc4random_uniform(ctMaxRounds)]
            
            
            for (idx,_) in newRounds.enumerate()
            {
                while newRounds[idx] == activeRotationRounds[dieIdx][idx] {
                    newRounds[idx] = 1+arc4random_uniform(ctMaxRounds)
                }
                activeRotationRounds[dieIdx][idx] = newRounds[idx]
                
            }
            
            var rndX = rotateAngleToDst(0, rounds: newRounds[0])
            var rndY = rotateAngleToDst(0, rounds: newRounds[1])
            let rndZ = rotateAngleToDst(0, rounds: newRounds[2])
            
            if num == 1
            {
                // ok
            }
            else if num == 2
            {
                rndY = rotateAngleToDst(-CGFloat(M_PI_2), rounds: newRounds[1])
            }
            else if num == 3
            {
                rndY = rotateAngleToDst(CGFloat(M_PI), rounds: newRounds[1])
            }
            else if num == 4
            {
                rndY = rotateAngleToDst(CGFloat(M_PI_2), rounds: newRounds[1])
            }
            else if num == 5
            {
                rndX = rotateAngleToDst(CGFloat(M_PI_2), rounds: newRounds[0])
            }
            else
            {
                rndX = rotateAngleToDst(-CGFloat(M_PI_2), rounds: newRounds[0])
            }
            
            let action = SCNAction.rotateToX(rndX, y: rndY, z: rndZ, duration: 1)
            let node = rootNode.childNodeWithName(String(dieIdx), recursively: false)!
            node.runAction(action)
        }
        
        if playSoundAction != nil
        {
            let cameraNode = rootNode.childNodeWithName("camera", recursively: false)
            cameraNode?.runAction(playSoundAction!)
        }
        
        dispatchToMainQueue(delay: 1.1) { 
            completion(result: values)
        }
    }
    
    func updateDiceSelection()
    {
        for dieIdx in 0..<Game.shared.diceNum.rawValue
        {
            if let dieNode = rootNode.childNodeWithName(String(dieIdx), recursively: false)
            {
                if Game.shared.diceHeld.contains(UInt(dieIdx))
                {
                    dieNode.geometry?.materials = dieMaterialsSelected
                }
                else
                {
                    dieNode.geometry?.materials = dieMaterialsDefault
                }
            }
        }
    }

}


