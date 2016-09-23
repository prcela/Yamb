//
//  DiceScene.swift
//  Yamb
//
//  Created by prcela on 16/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation

class DiceScene: SCNScene
{
    static let shared = DiceScene()
    
    var dieMaterialsDefault = [SCNMaterial]()
    var dieMaterialsSelected = [SCNMaterial]()
    
    
    var audioPlayers = [AVAudioPlayer]()
    
    override init() {
        super.init()
        
        let side: CGFloat = 1
        let delta: Float = 0.25
        
        for idx in 1...6
        {
            let soundURL = NSBundle.mainBundle().URLForResource(String(idx), withExtension: "m4a")!
            let audioPlayer = try! AVAudioPlayer(contentsOfURL: soundURL)
            audioPlayers.append(audioPlayer)
        }
        
        
        recreateMaterials()
        
        for dieIdx in 0..<Match.shared.diceNum.rawValue
        {
            let row = dieIdx / 3
            let col = dieIdx % 3
            
            let dieBox = SCNBox(width: side, height: side, length: side, chamferRadius: 0.1)
            dieBox.materials = dieMaterialsDefault
            
            let dieNode = SCNNode(geometry: dieBox)
            dieNode.name = String(dieIdx)
            dieNode.position = SCNVector3Make(Float(col)*(Float(side)+delta)+0.5*Float(side), Float(row)*(Float(side)+delta), 0)
            rootNode.addChildNode(dieNode)
            
            
        }
        
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 1.5
        cameraNode.position = SCNVector3Make(1.5*Float(side)+delta, 0.5*Float(side) + 0.5*delta, 30)
        
        rootNode.addChildNode(cameraNode)
        
        let light = SCNLight()
        light.type = SCNLightTypeSpot
        light.color = Skin.blue.defaultLightColor
        
        let lightNode = SCNNode()
        lightNode.name = "light"
        lightNode.light = light
        lightNode.position = SCNVector3Make(2,2,2)
        cameraNode.addChildNode(lightNode)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func recreateMaterials()
    {
        let player = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
        let dieMat = player.diceMaterial.rawValue
        dieMaterialsDefault.removeAll()
        dieMaterialsSelected.removeAll()
        
        for sideIdx in 1...6
        {
            let defaultMaterial = SCNMaterial()
            let name = "\(sideIdx)\(dieMat)"
            defaultMaterial.diffuse.contents = UIImage(named: name)
            defaultMaterial.locksAmbientWithDiffuse = true
            dieMaterialsDefault.append(defaultMaterial)
            
            let selectedMaterial = SCNMaterial()
            let selName = "\(name)_sel"
            selectedMaterial.diffuse.contents = UIImage(named: selName)
            selectedMaterial.locksAmbientWithDiffuse = true
            dieMaterialsSelected.append(selectedMaterial)
        }
        
        for dieIdx in 0..<Match.shared.diceNum.rawValue
        {
            if let dieNode = rootNode.childNodeWithName(String(dieIdx), recursively: false)
            {
                dieNode.geometry?.materials = dieMaterialsDefault
            }
        }
    }
    
    func start()
    {
        let match = Match.shared
        
        for idx in 0..<6
        {
            if let node = rootNode.childNodeWithName(String(idx), recursively: false)
            {
                node.rotation = SCNVector4Zero
            }
        }
        
        if let node = rootNode.childNodeWithName("5", recursively: false)
        {
            node.hidden = match.diceNum == .Five
        }
        updateDiceSelection()
    }

    func rollToValues(values: [UInt], ctMaxRounds: UInt32, completion: (Void) -> Void)
    {
        let player = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
        
        func rotateAngleToDst(dst:CGFloat, rounds: Int) -> CGFloat
        {
            return dst + CGFloat(rounds)*2*CGFloat(M_PI)
        }
        
        for dieIdx in 0..<Match.shared.diceNum.rawValue
        {
            let num = values[dieIdx]
            
            let rounds = player.activeRotationRounds[dieIdx]
            var rndX = rotateAngleToDst(0, rounds: rounds[0])
            var rndY = rotateAngleToDst(0, rounds: rounds[1])
            let rndZ = rotateAngleToDst(0, rounds: rounds[2])
            
            if num == 1
            {
                // ok
            }
            else if num == 2
            {
                rndY = rotateAngleToDst(-CGFloat(M_PI_2), rounds: rounds[1])
            }
            else if num == 3
            {
                rndY = rotateAngleToDst(CGFloat(M_PI), rounds: rounds[1])
            }
            else if num == 4
            {
                rndY = rotateAngleToDst(CGFloat(M_PI_2), rounds: rounds[1])
            }
            else if num == 5
            {
                rndX = rotateAngleToDst(CGFloat(M_PI_2), rounds: rounds[0])
            }
            else
            {
                rndX = rotateAngleToDst(-CGFloat(M_PI_2), rounds: rounds[0])
            }
            
            let duration: NSTimeInterval = 0.5 + 0.5*Double(max(rounds[0],rounds[1],rounds[2]))/Double(ctMaxRounds)
            let action = SCNAction.rotateToX(rndX, y: rndY, z: rndZ, duration: duration)
            action.timingMode = .EaseOut
            let node = rootNode.childNodeWithName(String(dieIdx), recursively: false)!
            node.runAction(action)
        }
        
        let ctRoll = Match.shared.diceNum.rawValue-player.diceHeld.count
        audioPlayers[ctRoll-1].play()
        
        dispatchToMainQueue(delay: 1.1) { 
            completion()
        }
    }
    
    func updateDiceSelection()
    {
        let player = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
        for dieIdx in 0..<Match.shared.diceNum.rawValue
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
        let player = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
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


