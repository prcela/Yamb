//
//  PrepareViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

private let diceMats:[DiceMaterial] = [.White, .Black, .Blue, .Rose, .Red, .Yellow]

class PrepareViewController: UIViewController {

    @IBOutlet weak var dice56Btn: UIButton?
    @IBOutlet weak var diceTextureBtn: UIButton?
    
    var diceMatSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let thinFont = UIFont(name: "AppleSDGothicNeo-Thin", size: 30)!
        let defaultFont = UIFont(name: "Apple SD Gothic Neo", size: 30)!
        
        let attrString = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.blackColor()
            ])
        
        let loc = title.characters.indexOf(Game.shared.diceNum == .Five ? "5":"6")!
        attrString.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.startIndex.distanceTo(loc), 1))
        
        
        dice56Btn?.setAttributedTitle(attrString, forState: .Normal)
        
        let current = diceMats[diceMatSelected]
        diceTextureBtn?.setImage(UIImage(named: "1\(current.rawValue)"), forState: .Normal)
        
    }
    
    @IBAction func toggleDiceCount(sender: AnyObject)
    {
        let old = Game.shared.diceNum
        Game.shared.diceNum = (old == .Five) ? .Six : .Five
        updateDiceBtn()
    }

    @IBAction func newGame(sender: AnyObject)
    {
        performSegueWithIdentifier("newId", sender: self)
    }
    
    @IBAction func resumeGame(sender: AnyObject)
    {
        if let game = GameFileManager.loadGame("singlePlayer")
        {
            Game.shared = game
            GameFileManager.deleteGame("singlePlayer")
        }
        navigationController!.performSegueWithIdentifier("playIdentifier", sender: nil)
    }
    
    @IBAction func changeDiceMaterial(sender: AnyObject)
    {
        diceMatSelected = (diceMatSelected+1)%diceMats.count
        let diceMat = diceMats[diceMatSelected]
        diceTextureBtn?.setImage(UIImage(named: "1\(diceMat.rawValue)"), forState: .Normal)
    }
    
    @IBAction func playNewGame(sender: AnyObject)
    {
        Game.shared.start(GameType.SinglePlayer, playersDesc: [(nil,diceMats[diceMatSelected])])
        navigationController!.performSegueWithIdentifier("playIdentifier", sender: nil)
        
    }

    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
