//
//  RetentionViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 20/12/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import SceneKit

class RetentionViewController: UIViewController {

    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var winLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let diceScene = DiceScene()
        scnView.scene = diceScene
        let randomIndex = Int(arc4random_uniform(UInt32(DiceMaterial.all.count)))
        diceScene.recreateMaterials(DiceMaterial.all[randomIndex])
        holderView.layer.cornerRadius = 10
    }

    @IBAction func roll(sender: AnyObject)
    {
        let diceScene = scnView.scene as! DiceScene
        var activeRotationRounds = [[Int]](count: 6, repeatedValue: [0,0,0])
        let ctMaxRounds:UInt32 = 5
        var values = [UInt]()
        for dieIdx in 0..<4
        {
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
        }
        diceScene.rollToValues(values, ctMaxRounds: ctMaxRounds, activeRotationRounds: activeRotationRounds, ctHeld: 0) {
            print("TODO")
        }
    }
}
