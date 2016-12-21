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
    @IBOutlet weak var rollBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var winLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    
    var ctDice = min(PlayerStat.shared.retentions.count,6)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let diceScene = DiceScene()
        scnView.scene = diceScene
        let randomIndex = Int(arc4random_uniform(UInt32(DiceMaterial.all.count)))
        diceScene.recreateMaterials(DiceMaterial.all[randomIndex])
        diceScene.start(ctDice)
        holderView.layer.cornerRadius = 10
        winLbl.hidden = true
        doneBtn.hidden = true
        
        rollBtn.setTitle(lstr("Roll"), forState: .Normal)
        doneBtn.setTitle(lstr("Done"), forState: .Normal)
        messageLbl.text = lstr("Reward for retention")
        dayLbl.text = "\(lstr("Day")) \(PlayerStat.shared.retentions.count)"
    }

    @IBAction func roll(sender: AnyObject)
    {
        let diceScene = scnView.scene as! DiceScene
        var activeRotationRounds = [[Int]](count: 6, repeatedValue: [0,0,0])
        let ctMaxRounds:UInt32 = 5
        var values = [UInt]()
        for dieIdx in 0..<ctDice
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
            let sum = values.reduce(0, combine: { (sum, val) -> UInt in
                return sum + val
            })
            self.winLbl.hidden = false
            self.winLbl.text = String(format: lstr("You win %d 💎"), sum)
            self.rollBtn.hidden = true
            self.doneBtn.hidden = false
            PlayerStat.shared.diamonds += Int(sum)
            PlayerStat.saveStat()
        }
    }
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
