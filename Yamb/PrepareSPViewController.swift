//
//  PrepareViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PrepareSPViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton?
    @IBOutlet weak var resumeBtn: UIButton?
    @IBOutlet weak var newGameBtn: UIButton?
    @IBOutlet weak var dice56Btn: UIButton?
    @IBOutlet weak var diceTextureBtn: UIButton?
    @IBOutlet weak var playBtn: UIButton?
    
    var diceMatSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // localization
        backBtn?.setTitle(lstr("Back"), forState: .Normal)
        resumeBtn?.setTitle(lstr("Resume game"), forState: .Normal)
        newGameBtn?.setTitle(lstr("New game"), forState: .Normal)
        playBtn?.setTitle(lstr("Play"), forState: .Normal)

        // Do any additional setup after loading the view.
        
        diceTextureBtn?.layer.cornerRadius = 5
        diceTextureBtn?.layer.borderColor = UIColor.lightGrayColor().CGColor
        diceTextureBtn?.layer.borderWidth = 1
        diceTextureBtn?.clipsToBounds = true
        
        diceMatSelected = PlayerStat.shared.ownedDiceMaterials().indexOf(PlayerStat.shared.favDiceMat)!
        updateDiceBtn()
        
    }

    func updateDiceBtn()
    {
        let title = lstr("Dice 5/6")
        let thinFont = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        let defaultFont = UIFont.systemFontOfSize(30)
        
        let attrString = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.blackColor()
            ])
        
        let loc = title.characters.indexOf(Match.shared.diceNum == .Five ? "5":"6")!
        attrString.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.startIndex.distanceTo(loc), 1))
        
        
        dice56Btn?.setAttributedTitle(attrString, forState: .Normal)
        
        let current = PlayerStat.shared.ownedDiceMaterials()[diceMatSelected]
        diceTextureBtn?.setImage(current.iconForValue(1), forState: .Normal)
        
    }
    
    @IBAction func toggleDiceCount(sender: AnyObject)
    {
        let old = Match.shared.diceNum
        Match.shared.diceNum = (old == .Five) ? .Six : .Five
        updateDiceBtn()
    }

    @IBAction func newGame(sender: AnyObject)
    {
        performSegueWithIdentifier("newId", sender: self)
    }
    
    @IBAction func resumeGame(sender: AnyObject)
    {
        if let match = GameFileManager.loadMatch(.SinglePlayer)
        {
            Match.shared = match
            GameFileManager.deleteGame("singlePlayer")
        }
        MainViewController.shared?.performSegueWithIdentifier("playIdentifier", sender: nil)
    }
    
    @IBAction func changeDiceMaterial(sender: AnyObject)
    {
        let diceMats = PlayerStat.shared.ownedDiceMaterials()
        diceMatSelected = (diceMatSelected+1)%diceMats.count
        let diceMat = diceMats[diceMatSelected]
        diceTextureBtn?.setImage(diceMat.iconForValue(1), forState: .Normal)
    }
    
    @IBAction func playNewGame(sender: AnyObject)
    {
        let playerId = PlayerStat.shared.id
        let playerAlias = PlayerStat.shared.alias
        let avgScore6 = PlayerStat.avgScore(.Six)
        let diceMat = PlayerStat.shared.ownedDiceMaterials()[diceMatSelected]
        Match.shared.start(.SinglePlayer,
                           diceNum: Match.shared.diceNum,
                           playersDesc: [(playerId,playerAlias,avgScore6,diceMat)],
                           matchId: 0,
                           bet: 0)
        MainViewController.shared?.performSegueWithIdentifier("playIdentifier", sender: nil)
    }

    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
