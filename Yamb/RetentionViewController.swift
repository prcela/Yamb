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
        winLbl.isHidden = true
        doneBtn.isHidden = true
        
        rollBtn.setTitle(lstr("Roll"), for: UIControlState())
        doneBtn.setTitle(lstr("Done"), for: UIControlState())
        messageLbl.text = lstr("Reward for retention")
        dayLbl.text = "\(lstr("Day")) \(PlayerStat.shared.retentions.count)"
    }

    @IBAction func roll(_ sender: AnyObject)
    {
        let diceScene = scnView.scene as! DiceScene
        var activeRotationRounds = [[Int]](repeating: [0,0,0], count: 6)
        let ctMaxRounds:UInt32 = 5
        var values = [UInt]()
        for dieIdx in 0..<ctDice
        {
            let num = UInt(1+arc4random_uniform(6))
            values.append(num)
            
            var newRounds = [Int(1+arc4random_uniform(ctMaxRounds)),
                             Int(1+arc4random_uniform(ctMaxRounds)),
                             Int(1+arc4random_uniform(ctMaxRounds))]
            
            
            for (idx,_) in newRounds.enumerated()
            {
                while newRounds[idx] == activeRotationRounds[dieIdx][idx] {
                    let dir = arc4random_uniform(2) == 0 ? -1:1
                    newRounds[idx] = dir*Int(1+arc4random_uniform(ctMaxRounds))
                }
                activeRotationRounds[dieIdx][idx] = newRounds[idx]
            }
        }
        diceScene.rollToValues(values, ctMaxRounds: ctMaxRounds, activeRotationRounds: activeRotationRounds, ctHeld: 0) {
            let sum = values.reduce(0, { (sum, val) -> UInt in
                return sum + val
            })
            self.winLbl.isHidden = false
            self.winLbl.text = String(format: lstr("You win %d 💎"), sum)
            self.rollBtn.isHidden = true
            self.doneBtn.isHidden = false
            PlayerStat.shared.diamonds += Int(sum)
            PlayerStat.saveStat()
        }
    }
    @IBAction func done(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
