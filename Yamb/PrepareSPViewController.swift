//
//  PrepareViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

let diceMats:[DiceMaterial] = [.White, .Black, .Blue, .Rose, .Red, .Yellow]

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
        updateDiceBtn()
        
        
        
        Chartboost.cacheInterstitial(CBLocationLevelStart)
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
        
        let current = diceMats[diceMatSelected]
        diceTextureBtn?.setImage(UIImage(named: "1\(current.rawValue)"), forState: .Normal)
        
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
        diceMatSelected = (diceMatSelected+1)%diceMats.count
        let diceMat = diceMats[diceMatSelected]
        diceTextureBtn?.setImage(UIImage(named: "1\(diceMat.rawValue)"), forState: .Normal)
    }
    
    @IBAction func playNewGame(sender: AnyObject)
    {
        Match.shared.start(.SinglePlayer, diceNum: Match.shared.diceNum, playersDesc: [(nil,nil,diceMats[diceMatSelected])])
        MainViewController.shared?.performSegueWithIdentifier("playIdentifier", sender: nil)
        
    }

    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
