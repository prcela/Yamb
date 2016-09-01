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
    
    var playSoundActions = [SCNAction]()
    
    var dieName = "b"
    var dieMaterialsDefault = [SCNMaterial]()
    var dieMaterialsSelected = [SCNMaterial]()
    
    var activeRotationRounds = Array<Array<Int>>(count: 6, repeatedValue: [0,0,0])
    
    override init() {
        super.init()
        
        let side: CGFloat = 1
        let delta: Float = 0.25
        
        for sideIdx in 1...6
        {
            let defaultMaterial = SCNMaterial()
            let name = "\(sideIdx)\(dieName)"
            defaultMaterial.diffuse.contents = UIImage(named: name)
            defaultMaterial.locksAmbientWithDiffuse = true
            dieMaterialsDefault.append(defaultMaterial)
            
            let selectedMaterial = SCNMaterial()
            let selName = "\(name)_sel"
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
        light.color = Skin.defaultLightColor
        
        let lightNode = SCNNode()
        lightNode.name = "light"
        lightNode.light = light
        cameraNode.addChildNode(lightNode)
        
        
        if #available(iOS 9.0, *) {
            
            var audioSources = [SCNAudioSource]()
            var audioPlayers = [SCNAudioPlayer]()
            
            
            for idx in 1...6
            {
                let audioSource = SCNAudioSource(fileNamed: "\(idx).m4a")!
                let audioPlayer = SCNAudioPlayer(source: audioSource)
                audioSources.append(audioSource)
                audioPlayers.append(audioPlayer)
            }
            
            
            dispatch_async(dispatch_get_main_queue(), {
                for audioPlayer in audioPlayers
                {
                    cameraNode.addAudioPlayer(audioPlayer)
                }
            })
            
            
            for audioSource in audioSources
            {
                playSoundActions.append(SCNAction.playAudioSource(audioSource, waitForCompletion: false))
            }
        }

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start()
    {
        let game = Game.shared
        
        for idx in 0..<6
        {
            if let node = rootNode.childNodeWithName(String(idx), recursively: false)
            {
                node.rotation = SCNVector4Zero
            }
        }
        
        if let node = rootNode.childNodeWithName("5", recursively: false)
        {
            node.hidden = game.diceNum == .Five
        }
        updateDiceSelection()
    }

    func roll(completion: (result: [UInt]) -> Void)
    {
        let ctMaxRounds: UInt32 = 3
        let player = Game.shared.players[Game.shared.idxPlayer]
        var oldValues = player.diceValues
        var values = [UInt]()
        
        func rotateAngleToDst(dst:CGFloat, rounds: Int) -> CGFloat
        {
            return dst + CGFloat(rounds)*2*CGFloat(M_PI)
        }
        
        for dieIdx in 0..<Game.shared.diceNum.rawValue
        {
            if player.diceHeld.contains(UInt(dieIdx))
            {
                // skip it by adding same value
                values.append(oldValues?[dieIdx] ?? 1)
                continue
            }
            
            let num = UInt(1+arc4random_uniform(6))
            values.append(num)
            
            var newRounds = [Int(1+arc4random_uniform(ctMaxRounds)),
                             Int(1+arc4random_uniform(ctMaxRounds)),
                             Int(1+arc4random_uniform(ctMaxRounds))]
            
            
            for (idx,_) in newRounds.enumerate()
            {
                while newRounds[idx] == activeRotationRounds[dieIdx][idx] {
                    let dir = arc4random_uniform(2) == 0 ? -1:1
                    newRounds[idx] = dir*Int(1+arc4random_uniform(ctMaxRounds))
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
            
            let duration: NSTimeInterval = 0.5 + 0.5*Double(max(newRounds[0],newRounds[1],newRounds[2]))/Double(ctMaxRounds)
            let action = SCNAction.rotateToX(rndX, y: rndY, z: rndZ, duration: duration)
            action.timingMode = .EaseOut
            let node = rootNode.childNodeWithName(String(dieIdx), recursively: false)!
            node.runAction(action)
        }
        
        if #available(iOS 9.0, *) {
            let ctRoll = Game.shared.diceNum.rawValue-player.diceHeld.count
            let playSoundAction = playSoundActions[ctRoll-1]

            let cameraNode = rootNode.childNodeWithName("camera", recursively: false)
            cameraNode?.runAction(playSoundAction)
        }
        
        dispatchToMainQueue(delay: 1.1) { 
            completion(result: values)
        }
    }
    
    func updateDiceSelection()
    {
        let player = Game.shared.players[Game.shared.idxPlayer]
        for dieIdx in 0..<Game.shared.diceNum.rawValue
        {
            if let dieNode = rootNode.childNodeWithName(String(dieIdx), recursively: false)
            {
                if player.diceHeld.contains(UInt(dieIdx))
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
    
    func updateDiceValues()
    {
        let player = Game.shared.players[Game.shared.idxPlayer]
        guard let values = player.diceValues else {return}
        
        for (idx,num) in values.enumerate()
        {
            var rndX:CGFloat = 0
            var rndY:CGFloat = 0
            let rndZ:CGFloat = 0
            
            if num == 1
            {
                // ok
            }
            else if num == 2
            {
                rndY = -CGFloat(M_PI_2)
            }
            else if num == 3
            {
                rndY = CGFloat(M_PI)
            }
            else if num == 4
            {
                rndY = CGFloat(M_PI_2)
            }
            else if num == 5
            {
                rndX = CGFloat(M_PI_2)
            }
            else
            {
                rndX = -CGFloat(M_PI_2)
            }
            let action = SCNAction.rotateToX(rndX, y: rndY, z: rndZ, duration: 0)
            let node = rootNode.childNodeWithName(String(idx), recursively: false)!
            node.runAction(action)
        }
    }

}


